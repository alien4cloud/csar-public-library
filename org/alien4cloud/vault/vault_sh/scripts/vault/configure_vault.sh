#!/bin/bash -e
source $commons/commons.sh
require_envs "AGENT_IP AGENT_API_PORT VAULT_IP VAULT_PORT"

sudo sed -i -e "s/%AGENT_IP%/${AGENT_IP}/g" /etc/vault/vault_config.hcl
sudo sed -i -e "s/%AGENT_API_PORT%/${AGENT_API_PORT}/g" /etc/vault/vault_config.hcl
sudo sed -i -e "s/%VAULT_IP%/${VAULT_IP}/g" /etc/vault/vault_config.hcl
sudo sed -i -e "s/%VAULT_PORT%/${VAULT_PORT}/g" /etc/vault/vault_config.hcl
