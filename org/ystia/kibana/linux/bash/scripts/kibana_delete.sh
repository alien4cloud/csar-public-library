#!/bin/bash

source ${utils_scripts}/utils.sh
# To set ELASTICSEARCH_HOME
source ${YSTIA_DIR}/kibana_env.sh

# Try to delete the most elements
set +e

log begin

log info "Remove systemd services"
sudo rm -f /etc/systemd/system/kibana.service /etc/systemd/system/elasticsearch.service
sudo systemctl daemon-reload
sudo systemctl reset-failed

log info "Remove all kibana related files"
sudo rm -rf ${HOME}/kibana-${KBN_VERSION}-linux-x86_64
sudo rm -rf ${HOME}/kibana-${KBN_VERSION}-linux-x86_64.tar.gz ${HOME}/kibana-${KBN_VERSION}-linux-x86_64.tar.gz.sha512 ${HOME}/kibana-${KBN_VERSION}-linux-x86_64.tar.gz.sha1
sudo rm -rf ${YSTIA_DIR}/kibana_env.sh

log info "Remove all elasticsearch client related files"
sudo rm -rf ${ELASTICSEARCH_HOME}*

log info "Remove all flags to avoid error when reinstalling it on a node"
sudo rm -rf ${YSTIA_DIR}/.${NODE}*

log end
