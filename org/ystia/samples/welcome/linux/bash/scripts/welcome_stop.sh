#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


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
