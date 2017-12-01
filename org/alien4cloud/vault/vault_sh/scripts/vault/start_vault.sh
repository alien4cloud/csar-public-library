#!/bin/bash -e
PIDFILE=/var/run/vault.pid
require_envs "VAULT_IP VAULT_PORT"

#1. Start the vault server
if [ -f $PIDFILE ]; then
  PID=`cat $PIDFILE`
  if [ -z "`ps axf | grep ${PID} | grep -v grep`" ]; then
    printf "%s\n" "Process dead but pidfile exists"
  else
    echo "Running"
  fi
else
  printf "%s\n" "Service not running, we start it"
  nohup bash -c 'vault server -config=/etc/vault/config.hcl & echo \$! > sudo ${PIDFILE}' &
fi

#2. Wait for the vault server up
until $(curl --output /dev/null --silent --head --fail http://$VAULT_IP:$VAULT_PORT); do
    printf '.'
    sleep 5
done

#3. Init the vault and save the unseal key
UNSEALED_KEYS_FILE=/etc/vault/unsealed_keys.txt
vault init >> $UNSEALED_KEYS_FILE

while IFS='' read -r line || [[ -n "$line" ]]; do
  if [[ $line == *"Initial Root Token"* ]]; then
    #We need to get the Root Token
    echo "Unable to unsealed vault."
    exit 1
  fi
  echo "Unseal vault with the key"
  #grep the key
  KEY=`cut -d ": " -f 2 <<< "$line"`
  #send the request
  RESPONSE=`curl \
              --request PUT \
              --data '{"key": $KEY}' \
              https://$VAULT_IP:$VAULT_PORT/v1/sys/unseal`
  if [[ $RESPONSE == *'"sealed": true'* ]]; then
    echo "Successfully unsealed vault !"
    break
  fi
done < "$UNSEALED_KEYS_FILE"

#4.
