variable "gcp_project_id" {
  type        = string
  description = "The ID of the GCP project where this template is to be deployed."
}

variable "gcp_region" {
  type        = string
  description = "The GCP region where this template is to be deployed."
}

variable "enable_apis" {
  type        = bool
  description = "Whether to automatically enable the necessary GCP APIs."
  default     = true
}

variable "github_repo_owner" {
  type        = string
  description = "The owner of the GitHub repository containing the service source code. E.g., in https://github.com/foo/bar, the owner is 'foo'."
}

variable "github_repo_name" {
  type        = string
  description = "The name of the GitHub repository containing the service source code. E.g., in https://github.com/foo/bar, the owner is 'bar'."
}

variable "branch_filter_regex" {
  type        = string
  description = "The regular expression to use when filtering repo branches. The build will run only if the branch matches this filter."
  default     = ".*"
}

variable "scheduled_build_branch_name" {
  type        = string
  description = "The name of the Git branch to pull when running scheduled builds."
  default     = "main"
}

variable "workstations_config_name" {
  type        = string
  description = "The full name of the Cloud Workstations configuration (e.g., projects/.../locations/.../workstationClusters/.../workstationConfigs/...)"
}