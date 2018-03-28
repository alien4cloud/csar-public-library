#!/bin/bash

source ${utils_scripts}/utils.sh

# Try to delete the most elements
set +e

log begin

log info "Remove systemd service"
sudo rm -f /etc/systemd/system/logstash.service
sudo systemctl daemon-reload
sudo systemctl reset-failed

log info "Remove all logstash related files"
sudo rm -rf $HOME/logstash-${LS_VERSION}
sudo rm -rf $HOME/logstash-${LS_VERSION}.tar.gz $HOME/logstash-${LS_VERSION}.tar.gz.sha512 $HOME/logstash-${LS_VERSION}.tar.gz.sha1
sudo rm -rf ${YSTIA_DIR}/${NODE}-service.env

log info "Remove all flags to avoid error when reinstalling it on a node"
sudo rm -rf ${YSTIA_DIR}/.${NODE}*

log end
