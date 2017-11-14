#!/usr/bin/env bash

source ${utils_scripts}/utils.sh
log begin

source ${lsscripts}/logstash_utils.sh

ensure_home_var_is_set

# get LOGSTASH_HOME
source ${YSTIA_DIR}/${HOST}-service.env

log info "Update Twitter full_tweet property: "
log info "    full_tweet: ${full_tweet}"

if [[ "$(grep -c "full_tweet" "${LOGSTASH_HOME}/conf/1-${NODE}_logstash_inputs.conf")" != "0" ]]; then
    replace_conf_value $LOGSTASH_HOME/conf/1-${NODE}_logstash_inputs.conf "full_tweet" $full_tweet || error_exit "Reconfiguration failed"
else
    add_conf_property $LOGSTASH_HOME/conf/1-${NODE}_logstash_inputs.conf "full_tweet" $full_tweet || error_exit "Reconfiguration failed"
fi

send_sighup_ifneeded

log end