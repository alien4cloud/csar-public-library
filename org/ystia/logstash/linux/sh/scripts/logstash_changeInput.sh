#!/usr/bin/env bash

source ${utils_scripts}/utils.sh
log begin

source ${scripts}/logstash_utils.sh

log info "Execute change input command with URL : $url"

replace_conf_file $LOGSTASH_HOME/conf/1-1_logstash_inputs.conf "input" $url || error_exit "Reconfiguration failed"

send_sighup_ifneeded

log end
