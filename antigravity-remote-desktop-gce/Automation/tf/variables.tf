variable "project_id" {
  description = "The GCP project ID to deploy into"
  type        = string
}

variable "region" {
  description = "The region for the VM"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The zone for the VM"
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  description = "The machine type for the desktop"
  type        = string
  default     = "e2-standard-4"
}

variable "disk_size_gb" {
  description = "The size of the persistent home disk in GB"
  type        = number
  default     = 100
}

variable "preemptible" {
  description = "Whether to use a preemptible (spot) instance to save costs"
  type        = bool
  default     = false
}
