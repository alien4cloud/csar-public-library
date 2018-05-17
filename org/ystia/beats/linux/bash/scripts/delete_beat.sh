#!/bin/bash

source ${utils_scripts}/utils.sh

# Try to delete the most elements
#set +e

log begin

SERVICE_NAME=$(basename -s .yml ${beat_v6_config})
log info "SERVICE_NAME=${SERVICE_NAME}"

log info "Remove systemd service"
sudo rm -f /etc/systemd/system/${SERVICE_NAME}.service
sudo systemctl daemon-reload
sudo systemctl reset-failed

log info "Remove all beat related files"
sudo rm -rf ${HOME}/${NODE}
rm -f ${SERVICE_NAME}-${BT_VERSION}-linux-x86_64.tar.gz

log info "Remove all flags to avoid error when reinstalling it on a node"
sudo rm -rf ${YSTIA_DIR}/.${NODE}*

log end
