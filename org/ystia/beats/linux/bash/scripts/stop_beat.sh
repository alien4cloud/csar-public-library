#!/usr/bin/env bash


source ${utils_scripts}/utils.sh

log begin

ensure_home_var_is_set

SERVICE_NAME=$(basename -s .yml ${beat_config})
log info "SERVICE_NAME=${SERVICE_NAME}"

sudo systemctl stop ${SERVICE_NAME}.service

log info "Beat component '${NODE}' stopped"
log end
