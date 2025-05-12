locals {
  proxmox_hosts = {
    "pve-1" = "10.0.0.6"
    "pve-2" = "10.0.0.7"
    "pve-3" = "10.0.0.8"
  }
}

module "proxmox_hosts" {
  for_each = local.proxmox_hosts

  source = "./modules/proxmox_hosts"

  name    = each.key
  ip      = each.value
  zone_id = data.cloudflare_zone.misery_systems.zone_id
}


resource "cloudflare_dns_record" "proxy_internal" {
  zone_id = data.cloudflare_zone.misery_systems.zone_id
  name    = "proxy.hosts.misery.systems"
  content = "10.0.0.136"
  type    = "A"
  ttl     = 1
}
