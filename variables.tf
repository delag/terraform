# GCP variables
variable "gcp_project_id" {
  description = "Google Cloud Platform (GCP) Project ID."
  type        = string
}

variable "region" {
  description = "GCP region name."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone name."
  type        = string
  default     = "us-central1-a"
}

variable "name" {
  description = "Web server name."
  type        = string
  default     = "web"
}

variable "machine_type" {
  description = "GCP VM instance machine type."
  type        = string
  default     = "n1-standard-1"
}

variable "labels" {
  description = "List of labels to attach to the VM instance."
  type        = map
}

# Cloudflare Variables
variable "cloudflare_zone" {
  description = "The Cloudflare zone to use."
  type        = string
}
