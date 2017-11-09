storage "consul" {
  address = "%AGENT_IP%:%AGENT_API_PORT%"
  path = "vault"
}

listener "tcp" {
 address = "127.0.0.1:%VAULT_PORT%"
 tls_disable = 1
}
