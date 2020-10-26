# DNS Records
resource "cloudflare_record" "apex" {
    zone_id = var.cloudflare_zone_id
    name    = var.cloudflare_zone
    value   = google_compute_instance.web.network_interface.0.access_config.0.nat_ip
    type    = "A"
    proxied = true
}

resource "cloudflare_record" "httpbin" {
    zone_id = var.cloudflare_zone_id
    name    = "httpbin"
    value   = google_compute_instance.web.network_interface.0.access_config.0.nat_ip
    type    = "A"
    proxied = true
}

resource "cloudflare_record" "api" {
    zone_id = var.cloudflare_zone_id
    name    = "api"
    value   = google_compute_instance.web.network_interface.0.access_config.0.nat_ip
    type    = "A"
    proxied = true
}

resource "cloudflare_record" "ghost" {
    zone_id = var.cloudflare_zone_id
    name    = "ghost"
    value   = google_compute_instance.web.network_interface.0.access_config.0.nat_ip
    type    = "A"
    proxied = true
}

resource "cloudflare_record" "wild" {
    zone_id = var.cloudflare_zone_id
    name    = "*"
    value   = google_compute_instance.web.network_interface.0.access_config.0.nat_ip
    type    = "A"
    proxied = true
}

output "DNS" {
    value = "httpbin.${var.cloudflare_zone}"
}
