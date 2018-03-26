#!/usr/bin/env bash

source ${utils_scripts}/utils.sh

set +e

log begin

ensure_home_var_is_set

INSTALL_DIR=$(eval readlink -f "${INSTALL_DIR}")

# TODO : DnsMasq uninstall ??

log info "Remove systemd service"
#sudo systemctl disable
sudo rm -f /etc/systemd/system/consul.service
sudo systemctl daemon-reload
sudo systemctl reset-failed

log info "Remove all consul related files"
rm -rf ${INSTALL_DIR}

log info "Remove all flags to avoid error when reinstalling it on a node"
rm -rf ${YSTIA_DIR}/consul_env.sh
rm -rf ${YSTIA_DIR}/.${NODE}*

log end
