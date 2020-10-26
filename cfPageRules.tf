# Page Rules
## Keep rules in order of priority! Do not add to the UI if using this method!

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
