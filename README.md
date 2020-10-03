# gcp/cf terraform (centOS)
Last update: Oct 2020

Terraform all the things

A terraform setup to kick a `n1-standard-1` instance in GCP with Cloudflare features/services in front of it.

Make sure to get your [GCP service user key](https://console.cloud.google.com/apis/credentials/serviceaccountkey) and save it to `terraformCreds.json` in the local directory or you could just update your credentials with the provider.

## TODO
* Add Authenticated Origin pull support

* Add Firewall Rules

* Argo Tunnel support to `template/install_server.tpl`

* Add Workers:

## HOWTO
* Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in appropriately. 

* Secure your credentials file for GCP by either using the link above or through `gcloud`.

* `terraform init` then `terraform plan --out=super.plan` then `terraform apply "super.plan"`

* Profit?
