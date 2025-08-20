# main.tf

resource "vault_policy" "transit" {
  name   = "pii-transit"
  policy = <<EOF
path "transit/encrypt/pii-key" {
  capabilities = ["update"]
}
path "transit/decrypt/pii-key" {
  capabilities = ["update"]
}
EOF
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "backend-default" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = var.kubernetes_host
  kubernetes_ca_cert     = data.local_sensitive_file.auth_backend_ca.content
  token_reviewer_jwt     = data.local_sensitive_file.auth_backend_jwt.content
  issuer                 = var.issuer
  disable_iss_validation = true
}

resource "vault_kubernetes_auth_backend_role" "sa-default" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "vault"
  bound_service_account_names      = ["vault"]
  bound_service_account_namespaces = ["vault-k3s"]
  token_ttl                        = 3600
  token_max_ttl                    = 7200
  token_policies                   = ["default", "pii-transit"]
  audience                         = "vault"
}

resource "vault_kubernetes_secret_backend" "config" {
  path                      = "kubernetes"
  description               = "Kubernetes authentication backend for Vault"
  default_lease_ttl_seconds = 43200
  max_lease_ttl_seconds     = 86400
  kubernetes_host           = var.kubernetes_host
  kubernetes_ca_cert        = data.local_sensitive_file.auth_backend_ca.content
  service_account_jwt       = data.local_sensitive_file.auth_backend_jwt.content
  disable_local_ca_jwt      = false
}

resource "vault_kubernetes_secret_backend_role" "sa-default" {
  backend                       = vault_kubernetes_secret_backend.config.path
  name                          = "vault"
  allowed_kubernetes_namespaces = ["vault-k3s"]
  token_default_ttl             = 43200
  token_max_ttl                 = 86400
  service_account_name          = "vault"
}

resource "vault_mount" "transit" {
  path                      = "transit"
  type                      = "transit"
  description               = "Transit secrets engine for encryption and decryption"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
}

resource "vault_transit_secret_cache_config" "cfg" {
  backend = vault_mount.transit.path
  size    = 1000
}

resource "vault_transit_secret_backend_key" "pii" {
  backend                = vault_mount.transit.path
  name                   = "pii-key"
  type                   = var.key_type
  exportable             = true
  allow_plaintext_backup = true
}