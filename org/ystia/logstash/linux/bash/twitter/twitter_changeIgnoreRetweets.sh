#!/usr/bin/env bash

source ${utils_scripts}/utils.sh
log begin

source ${lsscripts}/logstash_utils.sh

ensure_home_var_is_set

# get LOGSTASH_HOME
source ${YSTIA_DIR}/${HOST}-service.env

log info "Update Twitter ignore_retweets property: "
log info "    ignore_retweets: ${ignore_retweets}"

# reconfigure ignore_retweets property
if [[ "$(grep -c "ignore_retweets" "${LOGSTASH_HOME}/conf/1-${NODE}_logstash_inputs.conf")" != "0" ]]; then
    replace_conf_value $LOGSTASH_HOME/conf/1-${NODE}_logstash_inputs.conf "ignore_retweets" $ignore_retweets || error_exit "Reconfiguration failed"
else
    add_conf_property $LOGSTASH_HOME/conf/1-${NODE}_logstash_inputs.conf "ignore_retweets" $ignore_retweets || error_exit "Reconfiguration failed"
fi

send_sighup_ifneeded

log end