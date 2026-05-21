output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
  description = "GKE Cluster Host"
}

output "region" {
  value       = var.region
  description = "GCP region"
}

output "project_id" {
  value       = var.project_id
  description = "GCP project ID"
}

output "network_name" {
  value       = google_compute_network.vpc.name
  description = "VPC network name"
}

output "subnet_name" {
  value       = google_compute_subnetwork.subnet.name
  description = "Subnet name"
}

output "subnet_cidr" {
  value       = google_compute_subnetwork.subnet.ip_cidr_range
  description = "Subnet CIDR range"
}

output "pods_cidr" {
  value       = var.ip_range_pods
  description = "Pods secondary IP range"
}

output "services_cidr" {
  value       = var.ip_range_services
  description = "Services secondary IP range"
}

output "nat_ip" {
  value       = "See Cloud Console for NAT IP assignment"
  description = "Cloud NAT IP addresses (auto-assigned)"
}

output "cluster_ca_certificate" {
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
  description = "Cluster CA certificate"
}

output "configure_kubectl" {
  description = "Configure kubectl"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${var.region} --project ${var.project_id}"
}

output "workload_identity_provider" {
  value       = "iam.goog/projects/${data.google_client_config.default.project}/locations/global/workloadIdentityPools/gke-workload-identity/providers/gke"
  description = "Workload Identity Provider"
}

output "gke_service_account_email" {
  value       = google_service_account.gke.email
  description = "GKE service account email for Workload Identity"
}

output "private_cluster_enabled" {
  value       = google_container_cluster.primary.private_cluster_config[0].enable_private_nodes
  description = "Private cluster enabled status"
}

output "network_policy_enabled" {
  value       = google_container_cluster.primary.network_policy[0].enabled
  description = "Network Policy enabled status"
}

output "workload_identity_enabled" {
  value       = length(google_container_cluster.primary.workload_identity_config) > 0
  description = "Workload Identity enabled status"
}

output "shielded_nodes_enabled" {
  value       = google_container_cluster.primary.enable_shielded_nodes
  description = "Shielded Nodes enabled status"
}
