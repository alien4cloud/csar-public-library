#!/bin/bash -e
source $commons/commons.sh
require_envs "AGENT_IP AGENT_API_PORT VAULT_IP VAULT_PORT"

sudo sed -i -e "s/%AGENT_IP%/${AGENT_IP}/g" /etc/vault/vault_config.hcl
sudo sed -i -e "s/%AGENT_API_PORT%/${AGENT_API_PORT}/g" /etc/vault/vault_config.hcl
sudo sed -i -e "s/%VAULT_IP%/${VAULT_IP}/g" /etc/vault/vault_config.hcl
sudo sed -i -e "s/%VAULT_PORT%/${VAULT_PORT}/g" /etc/vault/vault_config.hcl

# Generate a certificate

TEMP_DIR=`mktemp -d`
CA_PEM_FILE=${TEMP_DIR}/ca.pem
echo "${CA_PEM}" > ${CA_PEM_FILE}
CA_KEY_FILE=${TEMP_DIR}/ca-key.pem
echo "${CA_KEY}" > ${CA_KEY_FILE}

echo "Generating a client key"
sudo openssl genrsa -out /etc/certs/vault.key 4096
sudo openssl req -subj "/CN=valt" -sha256 -new \
    -key /etc/certs/vault.key \
    -out ${TEMP_DIR}/vault.csr

# Sign the key with the CA and create a certificate
sudo echo "[ ssl_client ]" > ${TEMP_DIR}/extfile.cnf
sudo echo "extendedKeyUsage=serverAuth,clientAuth" >> ${TEMP_DIR}/extfile.cnf
	
 if [ ! -z "${VAULT_IP}" ]; then
    ALT_NAMES="IP:${VAULT_IP}"
 fi
 if [ ! -z "${PUBLIC_ADDRESS}" ]; then
    if [ ! -z "${ALT_NAMES}" ]; then
        ALT_NAMES="${ALT_NAMES},IP:${PUBLIC_ADDRESS}"
    else
        ALT_NAMES="IP:${PUBLIC_ADDRESS}"
    fi
fi

if [ ! -z "${ALT_NAMES}" ]; then
    sudo echo "subjectAltName = ${ALT_NAMES}" >> ${TEMP_DIR}/extfile.cnf
fi

echo "Generating a client certificate"
sudo openssl x509 -req -days 365 -sha256 \
    -in ${TEMP_DIR}/vault.csr -CA ${CA_PEM_FILE} -CAkey ${CA_KEY_FILE} \
    -CAcreateserial -out /etc/certs/vault.crt \
    -passin pass:$CA_PASSPHRASE \
    -extfile ${TEMP_DIR}/extfile.cnf -extensions ssl_client

sudo rm -Rf ${TEMP_DIR}