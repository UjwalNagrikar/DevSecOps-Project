output "load_balancer_ip" {
  description = "Global external IP address of the HTTP load balancer."
  value       = google_compute_global_forwarding_rule.app.ip_address
}

output "application_url" {
  description = "Public URL for the multi-region application."
  value       = "http://${google_compute_global_forwarding_rule.app.ip_address}"
}

output "mumbai_instance_group" {
  description = "Mumbai regional managed instance group URL."
  value       = google_compute_region_instance_group_manager.mumbai.instance_group
}

output "singapore_instance_group" {
  description = "Singapore regional managed instance group URL."
  value       = google_compute_region_instance_group_manager.singapore.instance_group
}

output "deployment_summary" {
  description = "High-level deployment summary."
  value = {
    project_id       = var.project_id
    mumbai_region    = var.mumbai_region
    singapore_region = var.singapore_region
    app_url          = "http://${google_compute_global_forwarding_rule.app.ip_address}"
  }
}
