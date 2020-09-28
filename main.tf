provider "google" {
credentials = "${file("terraformCreds.json")}"
project     = "snappy-catcher-266604"
region      = "us-central1"
}

