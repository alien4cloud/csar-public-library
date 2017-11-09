#!/bin/bash -e
source $commons/commons.sh
install_dependencies "unzip"
require_envs "VAULT_DOWNLOAD_URL VAULT_DATA_DIR"

if [ ! -d "/var/log/vault" ]; then
  sudo mkdir -p /var/log/vault
fi
if [ ! -d "$VAULT_DATA_DIR" ]; then
  sudo mkdir -p ${VAULT_DATA_DIR}
fi

VAULT_TMP_ZIP=/tmp/consul.zip
download "vault" "${VAULT_DOWNLOAD_URL}" ${VAULT_TMP_ZIP}

echo "Unzipping vault package to /usr/bin"
sudo unzip -o ${VAULT_TMP_ZIP} -d /usr/bin
echo "Unzipped vault package to /usr/bin"

sudo rm ${VAULT_TMP_ZIP}
