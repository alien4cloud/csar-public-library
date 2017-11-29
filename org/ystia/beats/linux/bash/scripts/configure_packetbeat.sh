#!/usr/bin/env bash

source ${utils_scripts}/utils.sh
log begin

ensure_home_var_is_set

if isServiceConfigured; then
    log info "PacketBeat component '${NODE}' already configured"
    exit 0
fi

install_dir=${HOME}/${NODE}
config_file=${install_dir}/packetbeat.yml

if [[ -n "${DEVICE}" ]]; then
    sed -i -e "s/device:.*$/device: ${DEVICE}/g" ${config_file}
fi

setServiceConfigured
log end
