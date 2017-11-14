#!/usr/bin/env bash

source ${utils_scripts}/utils.sh
log begin

source ${lsscripts}/logstash_utils.sh

ensure_home_var_is_set

# get LOGSTASH_HOME
source ${YSTIA_DIR}/${HOST}-service.env

log info "Update Twitter keywords property by adding value(s) in the array: "
log info "    keywords: ${keywords}"

# Reconfigure keywords property
add_values_in_array_property $LOGSTASH_HOME/conf/1-${NODE}_logstash_inputs.conf "keywords" "${keywords}" || error_exit "Reconfiguration failed"

send_sighup_ifneeded

log end