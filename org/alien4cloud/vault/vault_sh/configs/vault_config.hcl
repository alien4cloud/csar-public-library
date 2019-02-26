storage "consul" {
  address = "%AGENT_IP%:%AGENT_API_PORT%"
  scheme = "%AGENT_SCHEME%"
  path = "vault"
  tls_ca_file = "/etc/certs/vault_ca.pem"
  tls_cert_file = "/etc/certs/vault.crt"
  tls_key_file = "/etc/certs/vault.key"
}

listener "tcp" {
 address = "%VAULT_IP%:%VAULT_PORT%"
 tls_disable = %TLS_DISABLE%
 tls_cert_file = "/etc/certs/vault.crt"
 tls_key_file  = "/etc/certs/vault.key"
}
