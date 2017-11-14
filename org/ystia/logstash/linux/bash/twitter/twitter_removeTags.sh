#!/usr/bin/env bash

source ${utils_scripts}/utils.sh
log begin

source ${lsscripts}/logstash_utils.sh

ensure_home_var_is_set

# get LOGSTASH_HOME
source ${YSTIA_DIR}/${HOST}-service.env

log info "Update Twitter tags property by removing value(s) in the array: "
log info "    tags: ${tags}"

# Reconfigure tags property
remove_values_in_array_property $LOGSTASH_HOME/conf/1-${NODE}_logstash_inputs.conf "tags" "${tags}" || error_exit "Reconfiguration failed"

send_sighup_ifneeded

log end