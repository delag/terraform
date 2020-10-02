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

# Page Rules
resource "cloudflare_page_rule" "httpbin" {
    zone_id = var.cloudflare_zone_id
    target = "httpbin.${var.cloudflare_zone}/*"
    priority = 1
    actions {
        security_level = "essentially_off"
        waf = "off"
    }
}

resource "cloudflare_page_rule" "api" {
    zone_id = var.cloudflare_zone_id
    target = "api.${var.cloudflare_zone}/*"
    priority = 2
    actions {
        always_use_https = true
        cache_level = "bypass"
    }
}

resource "cloudflare_page_rule" "ghost" {
    zone_id = var.cloudflare_zone_id
    target = "ghost.${var.cloudflare_zone}/ghost*"
    priority = 3
    actions {
        always_use_https = true
        cache_level = "bypass"
        disable_security = true
        disable_performance = true
    }
}

output "DNS" {
    value = "httpbin.${var.cloudflare_zone}"
}
