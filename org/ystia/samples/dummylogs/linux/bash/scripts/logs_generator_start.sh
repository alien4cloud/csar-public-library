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
STOPPED_FLAG="${YSTIA_DIR}/.${NODE}-stopped"
rm -f ${STOP_FLAG}
rm -f ${STOPPED_FLAG}
mkdir -p $(dirname ${STOPPED_FLAG})

log info "Starting DummyLogsGenerator..."
INSTALL_DIR=${HOME}/${NODE}
PID_FILE="${YSTIA_DIR}/.${NODE}.pid"
nohup bash ${INSTALL_DIR}/dummylogs_start.sh $LOG_PATH $TOTAL_LOGS_NB $DELAY_S 1>/dev/null 2>&1 &
echo $! >${PID_FILE}

log end
