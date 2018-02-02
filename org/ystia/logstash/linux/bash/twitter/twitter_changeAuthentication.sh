#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#

source ${utils_scripts}/utils.sh
log begin

source ${lsscripts}/logstash_utils.sh

ensure_home_var_is_set

# get LOGSTASH_HOME
source ${YSTIA_DIR}/${HOST}-service.env

log info "Update Twitter authentication properties: "
log info "    consumer_key: ${consumer_key}"
log info "    consumer_secret: ${consumer_secret}"
log info "    oauth_token: ${oauth_token}"
log info "    oauth_token_secret: ${oauth_token_secret}"


if [[ "$(grep -c "consumer_key" "${LOGSTASH_HOME}/conf/1-${NODE}_logstash_inputs.conf")" != "0" ]]; then
    replace_conf_value $LOGSTASH_HOME/conf/1-${NODE}_logstash_inputs.conf "consumer_key" "\"$consumer_key\"" || error_exit "Reconfiguration failed"
else
    add_conf_property $LOGSTASH_HOME/conf/1-${NODE}_logstash_inputs.conf "consumer_key" "\"$consumer_key\"" || error_exit "Reconfiguration failed"
fi

if [[ "$(grep -c "consumer_secret" "${LOGSTASH_HOME}/conf/1-${NODE}_logstash_inputs.conf")" != "0" ]]; then
    replace_conf_value $LOGSTASH_HOME/conf/1-${NODE}_logstash_inputs.conf "consumer_secret" "\"$consumer_secret\"" || error_exit "Reconfiguration failed"
else
    add_conf_property $LOGSTASH_HOME/conf/1-${NODE}_logstash_inputs.conf "consumer_secret" "\"$consumer_secret\"" || error_exit "Reconfiguration failed"
fi

if [[ "$(grep -c "oauth_token" "${LOGSTASH_HOME}/conf/1-${NODE}_logstash_inputs.conf")" != "0" ]]; then
    replace_conf_value $LOGSTASH_HOME/conf/1-${NODE}_logstash_inputs.conf "oauth_token" "\"$oauth_token\"" || error_exit "Reconfiguration failed"
else
    add_conf_property $LOGSTASH_HOME/conf/1-${NODE}_logstash_inputs.conf "oauth_token" "\"$oauth_token\"" || error_exit "Reconfiguration failed"
fi

if [[ "$(grep -c "oauth_token_secret" "${LOGSTASH_HOME}/conf/1-${NODE}_logstash_inputs.conf")" != "0" ]]; then
    replace_conf_value $LOGSTASH_HOME/conf/1-${NODE}_logstash_inputs.conf "oauth_token_secret" "\"$oauth_token_secret\"" || error_exit "Reconfiguration failed"
else
    add_conf_property $LOGSTASH_HOME/conf/1-${NODE}_logstash_inputs.conf "oauth_token_secret" "\"$oauth_token_secret\"" || error_exit "Reconfiguration failed"
fi


send_sighup_ifneeded

log end