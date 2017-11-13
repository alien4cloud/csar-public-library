#!/usr/bin/env bash

source ${utils_scripts}/utils.sh
log begin

SAMPLEWEBSERVER_SRC=SampleWebServer.py
SAMPLEWEBSERVER_LOGS=${scripts}/SampleWebServer.logs
SAMPLEWEBSERVER_PID=${scripts}/SampleWebServer.pid

log info "Start python ${scripts}/${SAMPLEWEBSERVER_SRC} on port ${PORT}"
nohup python ${scripts}/${SAMPLEWEBSERVER_SRC} ${PORT} >> ${SAMPLEWEBSERVER_LOGS} 2>&1 &
echo "$!" > ${SAMPLEWEBSERVER_PID}

wait_for_port_to_be_open "127.0.0.1" "${PORT}" || error_exit "Cannot open port ${PORT}"

log end
