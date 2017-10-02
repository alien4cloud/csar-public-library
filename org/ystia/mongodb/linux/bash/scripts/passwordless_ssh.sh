#!/usr/bin/env bash

data=$1
utils_scripts=$2
. ${utils_scripts}/utils.sh
log begin

ensure_home_var_is_set

# Must be run under sudo or as user root.
  # Setup password-less ssh for user root
  log info "Setup password-less ssh for user root"
  if [[ ! -e /root/.ssh/id_rsa ]]; then
    log info "cp ${data}/id_rsa.txt /root/.ssh/id_rsa"
    cp ${data}/id_rsa.txt /root/.ssh/id_rsa
    chown root:root /root/.ssh/id_rsa
    chmod 600 /root/.ssh/id_rsa
  fi

  log info "cat ${data}/id_rsa.pub >> /root/.ssh/authorized_keys"
  cat ${data}/id_rsa.pub >> /root/.ssh/authorized_keys
  chown root:root /root/.ssh/authorized_keys
  chmod 644 /root/.ssh/authorized_keys

  # Setup password-less ssh for current user
  current_user=$(whoami)
  log info "Setup password-less ssh for user ${current_user}"
  if [[ ! -e ${HOME}/.ssh/id_rsa ]]; then
    log info "cp ${data}/id_rsa.txt ${HOME}/.ssh/id_rsa"
    cp ${data}/id_rsa.txt ${HOME}/.ssh/id_rsa
    chown ${current_user}:${current_user} ${HOME}/.ssh/id_rsa
    chmod 600 ${HOME}/.ssh/id_rsa
  fi

  log info "cat ${data}/id_rsa.pub >> ${HOME}/.ssh/authorized_keys"
  cat ${data}/id_rsa.pub >> ${HOME}/.ssh/authorized_keys
  chown ${current_user}:${current_user} ${HOME}/.ssh/authorized_keys
  chmod 644 ${HOME}/.ssh/authorized_keys

log info "END Password-less ssh install"

log end 