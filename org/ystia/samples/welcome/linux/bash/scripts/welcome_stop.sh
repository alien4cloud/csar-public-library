#!/usr/bin/env bash

source ${utils_scripts}/utils.sh
log begin

SAMPLEWEBSERVER_SRC=SampleWebServer.py
SAMPLEWEBSERVER_PID=${scripts}/SampleWebServer.pid
PID=`cat ${SAMPLEWEBSERVER_PID} 2>/dev/null`
if [ -n "${PID}" ]
then
    kill -15 ${PID}
    log info "SampleWebServer.py python script stopped"
fi

log end
