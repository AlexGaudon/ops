resource "kubernetes_namespace" "tailscale" {
  metadata {
    name = "tailscale"

    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "tailscale_tailnet_key" "k8s" {
  reusable      = true
  ephemeral     = true
  preauthorized = true
  expiry        = 90 * 24 * 60 * 60
}

resource "tailscale_tailnet_key" "droplet" {
  reusable      = true
  ephemeral     = true
  preauthorized = true
  expiry        = 90 * 24 * 60 * 60
}

resource "kubernetes_secret" "tailscale_auth" {
  metadata {
    name      = "tailscale-auth"
    namespace = kubernetes_namespace.tailscale.metadata[0].name
  }

  data = {
    TS_AUTHKEY = tailscale_tailnet_key.k8s.key
  }
}

module "cluster_router" {
  source = "./modules/subnet_router"

  count = 3

  router_name        = "k8s-cluster-router-${count.index}"
  namespace          = kubernetes_namespace.tailscale.id
  ts_auth_key_secret = kubernetes_secret.tailscale_auth.metadata[0].name
  routes             = ["10.0.0.0/8"]
  router_group       = "k8s-cluster-router"
}
