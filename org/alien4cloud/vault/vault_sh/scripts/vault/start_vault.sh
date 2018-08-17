#!/bin/bash -e
PIDFILE=/var/run/vault.pid
LOGFILE=/var/log/vault/log.out
source $commons/commons.sh
require_envs "VAULT_IP VAULT_PORT AUTO_UNSEALED TLS_DISABLE LDAP_ENABLE"

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
  sudo bash -c "nohup vault server -log-level=debug -config=/etc/vault/vault_config.hcl > ${LOGFILE} 2>&1 & echo \$! > ${PIDFILE}"
fi

echo "Export the environment variable VAULT_ADDR to $PROTOCOL://${VAULT_IP}:${VAULT_PORT}"
export VAULT_ADDR=$PROTOCOL://$VAULT_IP:$VAULT_PORT

sleep 10s

if [[ $AUTO_UNSEALED == true ]]; then
  echo "Init the vault and save the unseal key"
  UNSEALED_KEYS_FILE=/etc/vault/unsealed_keys.txt
  vault init -tls-skip-verify | sudo tee $UNSEALED_KEYS_FILE > /dev/null

  IFS=' ' read -r -a array <<< `sed "6q;d" $UNSEALED_KEYS_FILE`
  echo "Export the VAULT_TOKEN=${array[3]}"
  export VAULT_TOKEN="${array[3]}"

  while IFS='' read -r line || [[ -n "$line" ]]; do
    #grep the key
    IFS=' ' read -r -a array <<< $line
    KEY=${array[3]}
    echo "Unseal vault with the key $KEY"
    # #send the request
    RESPONSE=`curl \
                --insecure \
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

if [[ $LDAP_ENABLE == true ]]; then
  echo "Enable ldap !"
  vault auth-enable -tls-skip-verify ldap
  RESPONSE=`curl \
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
