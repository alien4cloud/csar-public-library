#!/bin/bash
source $commons/commons.sh
install_dependencies "jq"
require_envs "POLICY_NAME VAULT_ADDR UNSEALED_KEYS_FILE GROUP_ARRAY USER_ARRAY"

echo "export VAULT_ADDR=${VAULT_ADDR}"
export VAULT_ADDR=${VAULT_ADDR}

IFS=' ' read -r -a array <<< `sed "6q;d" $UNSEALED_KEYS_FILE`
echo "Exporting the VAULT_TOKEN=${array[3]}"
export VAULT_TOKEN="${array[3]}"

if [ ! -d "/etc/vault/policies/${POLICY_NAME}" ]; then
  sudo mkdir -p /etc/vault/policies/${POLICY_NAME}
fi
sudo cp ${policy_definition_file} /etc/vault/policies/${POLICY_NAME}/policy.hcl

echo "Writing the policy ${POLICY_NAME}"
vault policy-write -tls-skip-verify ${POLICY_NAME} ${policy_definition_file}

#'[ \"qa\", \"dev\" ]'

#-------update the policy for group-------------
#---parse a json array to bash array-------
groups=`echo $GROUP_ARRAY | tr -d '\\' 2> /dev/null | tr -d "'" `
len=${#groups}
groups="[${groups:2:len-4}]"
readarray -t array <<<"$(jq -r '.[]' <<<"$groups")"
#-------------------------------

for group in "${array[@]}"
do
  existing_policies=`vault read -tls-skip-verify -field=policies auth/ldap/groups/$group 2> /dev/null`
  echo "Group $group has the policies $existing_policies"
  if [[ -z "${existing_policies// }" ]];
  then
    updated_policies=${POLICY_NAME}
  else
    len=${#existing_policies}
    updated_policies=${existing_policies:1:len-2}','${POLICY_NAME}
  fi
  vault write -tls-skip-verify auth/ldap/groups/$group policies=$updated_policies
  echo "Update the policies of group $group to $updated_policies."
done
#-----------------------------------

#-------update the policy for user-------------
#---parse a json array to bash array-------
users=`echo $USER_ARRAY | tr -d '\\' 2> /dev/null | tr -d "'" `
len=${#users}
users="[${users:2:len-4}]"
readarray -t array <<<"$(jq -r '.[]' <<<"$users")"
#-------------------------------
for user in "${array[@]}"
do
  existing_policies=`vault read -tls-skip-verify -field=policies auth/ldap/users/$user 2> /dev/null`
  echo "User $user has the policies $existing_policies"
  if [[ -z "${existing_policies// }" ]];
  then
    updated_policies=${POLICY_NAME}
  else
    len=${#existing_policies}
    updated_policies=${existing_policies:1:len-2}','${POLICY_NAME}
  fi
  vault write -tls-skip-verify auth/ldap/users/$user policies=$updated_policies
  echo "Update the policies of user $user to $updated_policies."
done
#-----------------------------------
