storage "consul" {
  address = "%AGENT_IP%:%AGENT_API_PORT%"
  path = "vault"
}

listener "tcp" {
 address = "%VAULT_IP%:%VAULT_PORT%"
 tls_disable = 1
}
