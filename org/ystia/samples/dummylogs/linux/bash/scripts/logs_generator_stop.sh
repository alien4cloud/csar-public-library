#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#

source ${utils_scripts}/utils.sh
log begin
ensure_home_var_is_set

STOP_FLAG="${YSTIA_DIR}/.${NODE}-stop"
mkdir -p $(dirname ${STOP_FLAG})
touch ${STOP_FLAG}

log info "Stopping DummyLogsGenerator..."
PID_FILE="${YSTIA_DIR}/.${NODE}.pid"
[[ -r ${PID_FILE} ]] && kill -15 $(cat ${PID_FILE}) || log info "WARNING: Error when stopping DummyLogsGenerator"
rm -f ${PID_FILE}

log end
exit 0
