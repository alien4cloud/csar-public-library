#!/usr/bin/env bash

source ${utils_scripts}/utils.sh

set +e

log begin

ensure_home_var_is_set

log info "Remove systemd service"
sudo rm -f /etc/systemd/system/elasticsearch.service

log info "Remove all elasticsearch related files"
sudo rm -rf ${HOME}/elasticsearch-${ES_VERSION}
sudo rm -f ${HOME}/elasticsearch-${ES_VERSION}.tar.gz
sudo rm -f ${HOME}/elasticsearch-${ES_VERSION}.tar.gz.sha512

log info "Remove all flags to avoid error when reinstalling it on a node"
sudo rm -rf ${HOME}/.ystia/.Elasticsearch-*

log end