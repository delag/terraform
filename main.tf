# Specifying to use the GCP provider.
provider "google" {
  credentials = file("terraformCreds.json")
  project     = var.gcp_project_id
  region      = var.region
}

provider "cloudflare" {
    version = "~> 2.0"
    email   = "${var.cloudflare_email}"
    api_key = "${var.cloudflare_token}"
}

# Used to generate a random name for the GCP instance.
resource "random_id" "instance_id" {
  byte_length = 8
}

# Specify the version of terraform this works with.
terraform {
  required_version = ">= 0.12"
}
