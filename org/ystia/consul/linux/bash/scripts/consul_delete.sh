#!/usr/bin/env bash

source ${utils_scripts}/utils.sh

set +e

log begin

ensure_home_var_is_set

log info "Remove systemd service"
sudo rm -f /etc/systemd/system/consul.service

log info "Remove all consul related files"
rm -rf ${HOME}/consul

log info "Remove all flags to avoid error when reinstalling it on a node"
rm -rf ${HOME}/.ystia/consul*
rm -rf ${HOME}/.ystia/.Consul*

log end