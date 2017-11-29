#!/usr/bin/env bash

source ${utils_scripts}/utils.sh
log begin
ensure_home_var_is_set

log "Stoping DummyLogs Generator..."
STOP_FLAG="${HOME}/${YSTIA_DIR}/.${SELF}-stop"
mkdir -p $(dirname ${STOP_FLAG})
touch ${STOP_FLAG}
log end
exit 0