data "google_compute_image" "centos" {
  family  = "centos-7"
  project = "centos-cloud"
}

resource "google_compute_instance" "web" {
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["http-server", "ssh"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.centos.self_link
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = data.template_file.webServer.rendered

  metadata = {
    sshKeys = "dlg${file("/Users/cdlg/.ssh/id_rsa.pub")}"
  }
}

## Renders the data value passed above in metadata_startup_script
data "template_file" "webServer" {
  template = "${file("${path.module}/template/install_server.tpl")}"

  vars = {
    web_zone = var.cloudflare_zone
    cf_user  = var.cloudflare_email
    cf_api   = var.cloudflare_token
  }
}


resource "google_compute_firewall" "default" {
  name    = "nginx-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  allow {
    protocol = "icmp"
  }
}

output "ip" {
  value = google_compute_instance.web.network_interface[0].access_config[0].nat_ip
}
