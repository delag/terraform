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

# WAF Rules
# OWASP
## Data object for package_id variable
data "cloudflare_waf_packages" "owaspPackage" {
    zone_id = var.cloudflare_zone_id
    filter {
        name = "OWASP ModSecurity Core Rule Set"
    }
}

## Adjusting OWASP overall rulset
resource "cloudflare_waf_package" "owasp" {
    package_id = data.cloudflare_waf_packages.owaspPackage.packages.0.id
    zone_id = var.cloudflare_zone_id
    sensitivity = "medium"
    action_mode = "simulate"
}

## Adjusting individual rule behavior 
resource "cloudflare_waf_rule" "waf_rule_100000356" {
    rule_id = "100000356"
    zone_id = var.cloudflare_zone_id
    mode = "off"
}

# Cloudflare Managed Rulesets
## Data object for group_id variable
data "cloudflare_waf_groups" "drupal" {
    zone_id = var.cloudflare_zone_id
    filter {
        name = "Cloudflare Drupal"
    }
}

## Adjusting rulesets to be on or off
resource "cloudflare_waf_group" "drupal" {
    group_id = data.cloudflare_waf_groups.drupal.groups.0.id
    zone_id = var.cloudflare_zone_id
    mode = "off"
}

## Adjusting individual rule behavior
resource "cloudflare_waf_rule" "waf_rule_100000" {
    rule_id = "100000"
    zone_id = var.cloudflare_zone_id
    mode = "simulate"
}

#####
output "DNS" {
    value = "httpbin.${var.cloudflare_zone}"
}
