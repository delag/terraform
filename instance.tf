resource "random_id" "instance_id" {
byte_length = 8
}

resource "google_compute_instance" "web" {
name         = "web-vm-${random_id.instance_id.hex}"
machine_type = "f1-micro"
zone         = "us-central1-a"

boot_disk {
initialize_params {
image = "ubuntu-os-cloud/ubuntu-1804-lts"
}
}

metadata_startup_script = "${file("kickstart.sh")}"

network_interface {
network = "default"

access_config {

}
}

metadata {
sshKeys = "user:${file("/user/path/.ssh/id_rsa.pub")}"
}
}

resource "google_compute_firewall" "default" {
name    = "nginx-firewall"
network = "default"

allow {
protocol = "tcp"
ports    = ["80","443"]
}

allow {
protocol = "icmp"
}
}

output "ip" {
value = "${google_compute_instance.web.network_interface.0.access_config.0.nat_ip}"
}
