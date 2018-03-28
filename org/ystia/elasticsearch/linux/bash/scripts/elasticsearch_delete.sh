#!/usr/bin/env bash

source ${utils_scripts}/utils.sh

set +e

log begin

ensure_home_var_is_set

log info "Remove systemd service"
sudo rm -f /etc/systemd/system/elasticsearch.service
sudo systemctl daemon-reload
sudo systemctl reset-failed

log info "Remove all elasticsearch related files"
sudo rm -rf ${HOME}/elasticsearch-${ES_VERSION}
sudo rm -f ${HOME}/elasticsearch-${ES_VERSION}.tar.gz
sudo rm -f ${HOME}/elasticsearch-${ES_VERSION}.tar.gz.sha512 ${HOME}/elasticsearch-${ES_VERSION}.tar.gz.sha1
sudo rm -rf ${YSTIA_DIR}/${NODE}-*

log info "Remove all flags to avoid error when reinstalling it on a node"
sudo rm -rf ${YSTIA_DIR}/.${NODE}-*

log info "Uninstall elasticsearch-curator"
sudo crontab -u curator -r
sudo yum -y remove elasticsearch-curator

log end
