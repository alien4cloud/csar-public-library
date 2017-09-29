#!/usr/bin/env bash

source ${utils_scripts}/utils.sh
log begin

source ${scripts}/logstash_utils.sh

ensure_home_var_is_set

log info "Execute change filter command with URL : $url"

replace_conf_file $LOGSTASH_HOME/conf/2-1_logstash_filters.conf "filter" $url || error_exit "Reconfiguration failed"

send_sighup_ifneeded

log end

