storage "consul" {
  address = "%AGENT_IP%:%AGENT_API_PORT%"
  path = "vault"
}

listener "tcp" {
 address = "%VAULT_IP%:%VAULT_PORT%"
 tls_disable = %TLS_DISABLE%
 tls_cert_file = "/etc/certs/vault.crt"
 tls_key_file  = "/etc/certs/vault.key"
}
