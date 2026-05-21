# VPC Network with custom configuration
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  depends_on = [
    google_project_service.compute,
    google_project_service.container
  ]
}

# This file has been replaced with gke-cluster.tf which contains all GKE resources
# Including VPC, subnets, GKE cluster, node pools, KMS encryption, firewall rules, and service accounts
