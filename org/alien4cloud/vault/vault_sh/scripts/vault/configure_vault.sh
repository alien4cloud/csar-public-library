#!/bin/bash -e
source $commons/commons.sh
require_envs "AGENT_IP AGENT_API_PORT AGENT_TLS_ENABLED VAULT_IP VAULT_PORT"

AGENT_SCHEME="https"
if [ "$AGENT_TLS_ENABLED" != "true" ]; then
    AGENT_SCHEME="http"
fi

sudo sed -i -e "s/%AGENT_IP%/${AGENT_IP}/g" /etc/vault/vault_config.hcl
sudo sed -i -e "s/%AGENT_API_PORT%/${AGENT_API_PORT}/g" /etc/vault/vault_config.hcl
sudo sed -i -e "s/%AGENT_SCHEME%/${AGENT_SCHEME}/g" /etc/vault/vault_config.hcl
sudo sed -i -e "s/%VAULT_IP%/${VAULT_IP}/g" /etc/vault/vault_config.hcl
sudo sed -i -e "s/%VAULT_PORT%/${VAULT_PORT}/g" /etc/vault/vault_config.hcl

# Generate a certificate

echo "Generating a client key"
TEMP_DIR=`mktemp -d`
sudo openssl genrsa -out /etc/certs/vault.key 4096
sudo openssl req -subj "/CN=valt" -sha256 -new \
    -key /etc/certs/vault.key \
    -out ${TEMP_DIR}/vault.csr

# Storing the CA content and associated CA key content, both provided in parameter
CA_PEM_FILE=/etc/certs/vault_ca.pem
echo "${CA_PEM}" > ${TEMP_DIR}/vault_ca.pem
sudo cp ${TEMP_DIR}/vault_ca.pem ${CA_PEM_FILE}
CA_KEY_FILE=${TEMP_DIR}/ca-key.pem
echo "${CA_KEY}" > ${CA_KEY_FILE}

# Sign the key with the CA and create a certificate
sudo echo "[ ssl_client ]" > ${TEMP_DIR}/extfile.cnf
sudo echo "extendedKeyUsage=serverAuth,clientAuth" >> ${TEMP_DIR}/extfile.cnf
	
ALT_NAMES="IP:${VAULT_IP}"
 if [ ! -z "${PUBLIC_ADDRESS}" ]; then
    ALT_NAMES="${ALT_NAMES},IP:${PUBLIC_ADDRESS}"
fi

if [ ! -z "${ALT_NAMES}" ]; then
    sudo echo "subjectAltName = ${ALT_NAMES}" >> ${TEMP_DIR}/extfile.cnf
fi

echo "Generating a client certificate"
sudo openssl x509 -req -days 3650 -sha256 \
    -in ${TEMP_DIR}/vault.csr -CA ${CA_PEM_FILE} -CAkey ${CA_KEY_FILE} \
    -CAcreateserial -out /etc/certs/vault.crt \
    -passin pass:$CA_PASSPHRASE \
    -extfile ${TEMP_DIR}/extfile.cnf -extensions ssl_client

#sudo rm -Rf ${TEMP_DIR}