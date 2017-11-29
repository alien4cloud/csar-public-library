#!/usr/bin/env bash

source ${utils_scripts}/utils.sh
log begin

ensure_home_var_is_set

if isServiceConfigured; then
    log info "HeartBeat component '${NODE}' already configured"
    exit 0
fi

install_dir=${HOME}/${NODE}
config_file=${install_dir}/heartbeat.yml

sed -i -e "s/schedule:.*$/schedule: '@every ${SCHEDULE}s'/g" ${config_file}

setServiceConfigured
log end
