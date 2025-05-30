resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "flux" {
  repository = "ops"
  title      = "Flux"
  key        = tls_private_key.flux.public_key_openssh
  read_only  = false
}

resource "flux_bootstrap_git" "bootstrap" {
  depends_on = [github_repository_deploy_key.flux]

  path    = "flux"
  version = "v2.5.1"
  components_extra = [
    "image-reflector-controller",
    "image-automation-controller",
  ]
}
