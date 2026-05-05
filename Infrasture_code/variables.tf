variable "project_id" {
  description = "GCP project ID where the infrastructure will be deployed."
  type        = string
}

variable "credentials_file" {
  description = "Optional path to a GCP service account JSON key. Leave empty to use Application Default Credentials."
  type        = string
  default     = ""
}

variable "app_name" {
  description = "Application name used for GCP resource names and labels."
  type        = string
  default     = "gcp-multi-region-app"
}

variable "default_region" {
  description = "Default provider region."
  type        = string
  default     = "asia-south1"
}

variable "mumbai_region" {
  description = "GCP Mumbai region."
  type        = string
  default     = "asia-south1"
}

variable "singapore_region" {
  description = "GCP Singapore region."
  type        = string
  default     = "asia-southeast1"
}

variable "mumbai_zones" {
  description = "Zones for the regional managed instance group in Mumbai."
  type        = list(string)
  default     = ["asia-south1-a", "asia-south1-b"]
}

variable "singapore_zones" {
  description = "Zones for the regional managed instance group in Singapore."
  type        = list(string)
  default     = ["asia-southeast1-a", "asia-southeast1-b"]
}

variable "mumbai_subnet_cidr" {
  description = "CIDR block for the Mumbai subnet."
  type        = string
  default     = "10.10.0.0/20"
}

variable "singapore_subnet_cidr" {
  description = "CIDR block for the Singapore subnet."
  type        = string
  default     = "10.20.0.0/20"
}

variable "machine_type" {
  description = "Compute Engine machine type for application instances."
  type        = string
  default     = "e2-micro"
}

variable "source_image" {
  description = "Boot disk image for application instances."
  type        = string
  default     = "projects/debian-cloud/global/images/family/debian-12"
}

variable "app_port" {
  description = "Application HTTP port."
  type        = number
  default     = 80
}

variable "min_replicas" {
  description = "Minimum number of instances per region."
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Maximum number of instances per region."
  type        = number
  default     = 3
}

variable "cpu_target" {
  description = "Target CPU utilization for regional autoscalers."
  type        = number
  default     = 0.6
}

variable "enable_ssh" {
  description = "Whether to allow SSH access to instances."
  type        = bool
  default     = false
}

variable "ssh_source_ranges" {
  description = "CIDR ranges allowed to SSH when enable_ssh is true."
  type        = list(string)
  default     = []
}
