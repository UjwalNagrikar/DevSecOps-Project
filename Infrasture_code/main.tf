locals {
  labels = {
    app        = var.app_name
    managed_by = "terraform"
  }

  health_check_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]
}

resource "google_compute_network" "app" {
  name                    = "${var.app_name}-vpc"
  auto_create_subnetworks = false
  description             = "Custom VPC for the multi-region application."
}

resource "google_compute_subnetwork" "mumbai" {
  name          = "${var.app_name}-mumbai-subnet"
  ip_cidr_range = var.mumbai_subnet_cidr
  region        = var.mumbai_region
  network       = google_compute_network.app.id
  description   = "Mumbai application subnet."
}

resource "google_compute_subnetwork" "singapore" {
  name          = "${var.app_name}-singapore-subnet"
  ip_cidr_range = var.singapore_subnet_cidr
  region        = var.singapore_region
  network       = google_compute_network.app.id
  description   = "Singapore application subnet."
}

resource "google_compute_firewall" "allow_http_from_lb" {
  name          = "${var.app_name}-allow-http-lb"
  network       = google_compute_network.app.name
  description   = "Allow Google load balancer and health check traffic to application instances."
  source_ranges = local.health_check_ranges
  target_tags   = ["${var.app_name}-web"]

  allow {
    protocol = "tcp"
    ports    = [tostring(var.app_port)]
  }
}

resource "google_compute_firewall" "allow_ssh" {
  count         = var.enable_ssh ? 1 : 0
  name          = "${var.app_name}-allow-ssh"
  network       = google_compute_network.app.name
  description   = "Optional SSH access for troubleshooting."
  source_ranges = var.ssh_source_ranges
  target_tags   = ["${var.app_name}-web"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_health_check" "app" {
  name               = "${var.app_name}-http-health-check"
  description        = "HTTP health check for the multi-region application."
  check_interval_sec = 10
  timeout_sec        = 5

  http_health_check {
    port         = var.app_port
    request_path = "/"
  }
}

resource "google_compute_instance_template" "mumbai" {
  name_prefix  = "${var.app_name}-mumbai-"
  machine_type = var.machine_type
  tags         = ["${var.app_name}-web"]
  labels       = local.labels

  disk {
    auto_delete  = true
    boot         = true
    source_image = var.source_image
  }

  network_interface {
    subnetwork = google_compute_subnetwork.mumbai.id

    access_config {
      network_tier = "PREMIUM"
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -euo pipefail

    apt-get update -y
    apt-get install -y nginx

    cat >/var/www/html/index.html <<HTML
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>${var.app_name} - Mumbai</title>
      </head>
      <body>
        <main style="font-family: Arial, sans-serif; padding: 48px; text-align: center;">
          <h1>${var.app_name}</h1>
          <p>Application is running in Mumbai on Google Cloud.</p>
        </main>
      </body>
    </html>
    HTML

    systemctl enable nginx
    systemctl restart nginx
  EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_template" "singapore" {
  name_prefix  = "${var.app_name}-singapore-"
  machine_type = var.machine_type
  tags         = ["${var.app_name}-web"]
  labels       = local.labels

  disk {
    auto_delete  = true
    boot         = true
    source_image = var.source_image
  }

  network_interface {
    subnetwork = google_compute_subnetwork.singapore.id

    access_config {
      network_tier = "PREMIUM"
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -euo pipefail

    apt-get update -y
    apt-get install -y nginx

    cat >/var/www/html/index.html <<HTML
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>${var.app_name} - Singapore</title>
      </head>
      <body>
        <main style="font-family: Arial, sans-serif; padding: 48px; text-align: center;">
          <h1>${var.app_name}</h1>
          <p>Application is running in Singapore on Google Cloud.</p>
        </main>
      </body>
    </html>
    HTML

    systemctl enable nginx
    systemctl restart nginx
  EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "mumbai" {
  name                      = "${var.app_name}-mumbai-mig"
  base_instance_name        = "${var.app_name}-mumbai"
  region                    = var.mumbai_region
  distribution_policy_zones = var.mumbai_zones
  target_size               = var.min_replicas

  version {
    instance_template = google_compute_instance_template.mumbai.id
  }

  named_port {
    name = "http"
    port = var.app_port
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.app.id
    initial_delay_sec = 120
  }
}

resource "google_compute_region_instance_group_manager" "singapore" {
  name                      = "${var.app_name}-singapore-mig"
  base_instance_name        = "${var.app_name}-singapore"
  region                    = var.singapore_region
  distribution_policy_zones = var.singapore_zones
  target_size               = var.min_replicas

  version {
    instance_template = google_compute_instance_template.singapore.id
  }

  named_port {
    name = "http"
    port = var.app_port
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.app.id
    initial_delay_sec = 120
  }
}

resource "google_compute_region_autoscaler" "mumbai" {
  name   = "${var.app_name}-mumbai-autoscaler"
  region = var.mumbai_region
  target = google_compute_region_instance_group_manager.mumbai.id

  autoscaling_policy {
    min_replicas    = var.min_replicas
    max_replicas    = var.max_replicas
    cooldown_period = 60

    cpu_utilization {
      target = var.cpu_target
    }
  }
}

resource "google_compute_region_autoscaler" "singapore" {
  name   = "${var.app_name}-singapore-autoscaler"
  region = var.singapore_region
  target = google_compute_region_instance_group_manager.singapore.id

  autoscaling_policy {
    min_replicas    = var.min_replicas
    max_replicas    = var.max_replicas
    cooldown_period = 60

    cpu_utilization {
      target = var.cpu_target
    }
  }
}

resource "google_compute_backend_service" "app" {
  name                  = "${var.app_name}-backend"
  description           = "Global backend service for Mumbai and Singapore application groups."
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  timeout_sec           = 30
  health_checks         = [google_compute_health_check.app.id]

  backend {
    group           = google_compute_region_instance_group_manager.mumbai.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }

  backend {
    group           = google_compute_region_instance_group_manager.singapore.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_url_map" "app" {
  name            = "${var.app_name}-url-map"
  description     = "URL map for the global HTTP load balancer."
  default_service = google_compute_backend_service.app.id
}

resource "google_compute_target_http_proxy" "app" {
  name    = "${var.app_name}-http-proxy"
  url_map = google_compute_url_map.app.id
}

resource "google_compute_global_forwarding_rule" "app" {
  name                  = "${var.app_name}-http-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.app.id
}
