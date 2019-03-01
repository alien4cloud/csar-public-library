#!/bin/bash -e
PIDFILE=/var/run/vault.pid
LOGFILE=/var/log/vault/log.out
source $commons/commons.sh
require_envs "VAULT_IP VAULT_PORT AUTO_UNSEALED TLS_DISABLE LDAP_ENABLE"
set -x
echo "Update the vault_config file"
sudo sed -i -e "s/%TLS_DISABLE%/${TLS_DISABLE}/g" /etc/vault/vault_config.hcl

PROTOCOL=https
if [[ $TLS_DISABLE == true ]]; then
  PROTOCOL=http
fi

if [ -f $PIDFILE ]; then
  PID=`cat $PIDFILE`
  if [ -z "`ps axf | grep ${PID} | grep -v grep`" ]; then
    printf "%s\n" "Process dead but pidfile exists"
  else
    echo "Running"
  fi
else
  printf "%s\n" "Vault not running, we start vault server"
  if [ -z "${NO_PROXY}" ]; then
      NO_PROXY_VAULT=$VAULT_IP
  else
      NO_PROXY_VAULT=$VAULT_IP,$NO_PROXY
  fi
  export NO_PROXY=$NO_PROXY_VAULT
  sudo bash -c "nohup vault server -config=/etc/vault/vault_config.hcl > ${LOGFILE} 2>&1 & echo \$! > ${PIDFILE}"
fi

echo "Export the environment variable VAULT_ADDR to $PROTOCOL://${VAULT_IP}:${VAULT_PORT}"
export VAULT_ADDR=$PROTOCOL://$VAULT_IP:$VAULT_PORT

# Exporting env. variables related to certificates, to use the CLI
export VAULT_CACERT=/etc/certs/vault_ca.pem
export VAULT_CLIENT_CERT=/etc/certs/vault.crt
export VAULT_CLIENT_KEY=/etc/certs/vault.key

sleep 10s

if [[ $AUTO_UNSEALED == true ]]; then
  echo "Init the vault and save the unseal key"
  UNSEALED_KEYS_FILE=/etc/vault/unsealed_keys.txt
#  vault init -tls-skip-verify | sudo tee $UNSEALED_KEYS_FILE > /dev/null
  vault operator init | sudo tee $UNSEALED_KEYS_FILE > /dev/null

  IFS=' ' read -r -a array <<< `sed "7q;d" $UNSEALED_KEYS_FILE`
  echo "Export the VAULT_TOKEN=${array[3]}"
  export VAULT_TOKEN="${array[3]}"

  VAULT_TOKEN_ENCRYPTED=`echo -n $VAULT_TOKEN | openssl enc -aes256 -base64 -pass pass:$PASSPHRASE`

  while IFS='' read -r line || [[ -n "$line" ]]; do
    #grep the key
    IFS=' ' read -r -a array <<< $line
    KEY=${array[3]}
    echo "Unseal vault with the key $KEY"
    # #send the request
    RESPONSE=`curl \
      --noproxy $VAULT_IP --cacert $VAULT_CACERT --key $VAULT_CLIENT_KEY --cert $VAULT_CLIENT_CERT \
      --request PUT \
      --data '{"key": "'${KEY}'"}' \
      $PROTOCOL://$VAULT_IP:$VAULT_PORT/v1/sys/unseal`
    echo $RESPONSE
    if [[ $RESPONSE == *'"sealed":false'* ]]; then
      echo "Successfully unsealed vault !"
      break
    fi
  done < "$UNSEALED_KEYS_FILE"
fi
sudo chmod 600 $UNSEALED_KEYS_FILE

if [[ $LDAP_ENABLE == true ]]; then
  echo "Enable ldap !"
  vault auth-enable -tls-skip-verify ldap
  RESPONSE=`curl \
    --noproxy $VAULT_IP --cacert $VAULT_CACERT --key $VAULT_CLIENT_KEY --cert $VAULT_CLIENT_CERT \
    -k \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data @/etc/vault/ldap_config.json \
    $PROTOCOL://$VAULT_IP:$VAULT_PORT/v1/auth/ldap/config`
  echo $RESPONSE
  if [[ $RESPONSE == *'"errors:"'* ]]; then
    exit 1
  fi
fi
