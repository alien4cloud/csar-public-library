#!/bin/bash -e
source $commons/commons.sh
install_dependencies "unzip"
require_envs "VAULT_DOWNLOAD_URL VAULT_INSTALL_DIR"

if [ ! -d "/var/log/vault" ]; then
  sudo mkdir -p /var/log/vault
fi
if [ ! -d "$VAULT_INSTALL_DIR" ]; then
  sudo mkdir -p ${VAULT_INSTALL_DIR}
fi
if [ ! -d "/etc/vault" ]; then
  sudo mkdir -p /etc/vault
fi

VAULT_TMP_ZIP=/tmp/consul.zip
download "vault" "${VAULT_DOWNLOAD_URL}" ${VAULT_TMP_ZIP}

echo "Unzipping vault package to /usr/bin"
sudo unzip -o ${VAULT_TMP_ZIP} -d /usr/bin
echo "Unzipped vault package to /usr/bin"

sudo rm ${VAULT_TMP_ZIP}

cp $config/vault/config.hcl /etc/vault/config.hcl

./usr/bin/vault mount consul
