#!/usr/bin/env bash

source ${utils_scripts}/utils.sh
log begin

source ${lsscripts}/logstash_utils.sh

ensure_home_var_is_set

# get LOGSTASH_HOME
source ${YSTIA_DIR}/${HOST}-service.env

log info "Update Twitter languages property by removing value(s) in the array: "
log info "    languages: ${languages}"

# Reconfigure languages property
remove_values_in_array_property $LOGSTASH_HOME/conf/1-${NODE}_logstash_inputs.conf "languages" "${languages}" || error_exit "Reconfiguration failed"

send_sighup_ifneeded

log end