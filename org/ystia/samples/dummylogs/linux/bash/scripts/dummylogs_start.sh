#!/usr/bin/env bash

source ${utils_scripts}/utils.sh

source ${utils_scripts}/utils.sh
log begin
ensure_home_var_is_set

[ $# -ne 3 ] && exit 1

STOP_FLAG="${HOME}/${YSTIA_DIR}/.${SELF}-stop"
STOPPED_FLAG="${HOME}/${YSTIA_DIR}/.${SELF}-stopped"

LOG_PATH=$1
TOTAL_LOGS_NB=$2
DELAY_S=$3

hostname=$(hostname)
mkdir -p $(dirname ${LOG_PATH})

>$LOG_PATH
for (( c=1; c<=$TOTAL_LOGS_NB; c++ ))
do
    DATE=`date +"%d-%m-%Y %H:%M:%S.000"`
    echo "${DATE} - hostname=${hostname},logfile=${LOG_PATH},nb=${c}" >>$LOG_PATH
    if [[ -f ${STOP_FLAG} ]]; then
        break
    fi
    sleep $DELAY_S
done

while [[ "1" == "1"  ]] ; do
    if [[ -f ${STOP_FLAG} ]]; then
        break
    fi
    sleep 10
done

touch ${STOPPED_FLAG}
log end

exit 0