#!/bin/bash

source ${utils_scripts}/utils.sh

# Try to delete the most elements
set +e

log begin

log info "Remove systemd service"
sudo rm -f /etc/systemd/system/kibana.service

log info "Remove all kibana related files"
sudo rm -rf ${HOME}/kibana-${KBN_VERSION}-linux-x86_64
sudo rm -rf ${HOME}/kibana-${KBN_VERSION}-linux-x86_64.tar.gz

log info "Remove all flags to avoid error when reinstalling it on a node"
sudo rm -rf ${HOME}/.ystia/.Kibana*

log end
