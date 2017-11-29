#!/usr/bin/env bash

source ${utils_scripts}/utils.sh
log begin
ensure_home_var_is_set

STOP_FLAG="${HOME}/${YSTIA_DIR}/.${SELF}-stop"
STOPPED_FLAG="${HOME}/${YSTIA_DIR}/.${SELF}-stopped"
rm -f ${STOP_FLAG}
rm -f ${STOPPED_FLAG}
mkdir -p $(dirname ${STOPPED_FLAG})

log "Starting DummyLogs Generator..."
nohup bash ${scripts}/dummylogs_start.sh $LOG_PATH $TOTAL_LOGS_NB $DELAY_S 1>/dev/null 2>&1 &

log end
