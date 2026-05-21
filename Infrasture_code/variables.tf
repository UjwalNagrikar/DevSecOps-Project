variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "devsecops-gke-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version for GKE"
  type        = string
  default     = "1.27"
}

variable "node_count" {
  description = "Initial number of nodes in the cluster"
  type        = number
  default     = 3
}

variable "min_node_count" {
  description = "Minimum number of nodes in node pool"
  type        = number
  default     = 2
}

variable "max_node_count" {
  description = "Maximum number of nodes in node pool"
  type        = number
  default     = 10
}

variable "machine_type" {
  description = "Machine type for nodes"
  type        = string
  default     = "e2-standard-4"
}

variable "disk_size_gb" {
  description = "Disk size in GB for nodes"
  type        = number
  default     = 50
}

variable "network_name" {
  description = "VPC network name"
  type        = string
  default     = "devsecops-vpc"
}

variable "subnet_name" {
  description = "Subnet name for GKE"
  type        = string
  default     = "devsecops-subnet"
}

variable "ip_range_pods" {
  description = "IP range for pods"
  type        = string
  default     = "10.4.0.0/14"
}

variable "ip_range_services" {
  description = "IP range for services"
  type        = string
  default     = "10.0.0.0/20"
}

variable "subnet_cidr" {
  description = "CIDR range for subnet"
  type        = string
  default     = "10.128.0.0/20"
}

variable "nat_name" {
  description = "Cloud NAT name"
  type        = string
  default     = "devsecops-nat"
}

variable "router_name" {
  description = "Cloud Router name"
  type        = string
  default     = "devsecops-router"
}

variable "enable_binary_authorization" {
  description = "Enable Binary Authorization"
  type        = bool
  default     = true
}

variable "enable_network_policy" {
  description = "Enable Network Policy for the cluster"
  type        = bool
  default     = true
}

variable "enable_workload_identity" {
  description = "Enable Workload Identity for the cluster"
  type        = bool
  default     = true
}

variable "enable_shielded_nodes" {
  description = "Enable Shielded Nodes for the cluster"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "labels" {
  description = "Common labels for resources"
  type        = map(string)
  default = {
    environment = "devsecops"
    managed_by  = "terraform"
  }
}

variable "ssh_source_ranges" {
  description = "CIDR ranges allowed to SSH when enable_ssh is true."
  type        = list(string)
  default     = []
}
