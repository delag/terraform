# Specifying to use the GCP provider.
provider "google" {
  credentials = file("terraformCreds.json")
  project     = var.gcp_project_id
  region      = var.region
}

# Used to generate a random name for the GCP instance.
resource "random_id" "instance_id" {
  byte_length = 8
}

# Specify the version of terraform this works with.
terraform {
  required_version = ">= 0.12"
}
