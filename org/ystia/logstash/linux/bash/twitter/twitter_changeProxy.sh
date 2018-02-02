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

log info "Update Twitter proxy properties: "
log info "    use_proxy: ${use_proxy}"
log info "    proxy_address: ${proxy_address}"
log info "    proxy_port: ${proxy_port}"


TWITTER_INPUT_PATH=${LOGSTASH_HOME}/conf/1-${NODE}_logstash_inputs.conf

# Configure use_proxy property
if [[ "$(grep -c "use_proxy" "${TWITTER_INPUT_PATH}")" != "0" ]]; then
    replace_conf_value ${TWITTER_INPUT_PATH} "use_proxy" $use_proxy || error_exit "Reconfiguration failed"
else
    add_conf_property ${TWITTER_INPUT_PATH} "use_proxy" $use_proxy || error_exit "Reconfiguration failed"
fi

# Configure proxy_address property
if [[ ${use_proxy} == "false" ]]; then
    # if use_proxy is set to false and proxy_address property exists in config file, delete it
    if [[ "$(grep -c "proxy_address" "${TWITTER_INPUT_PATH}")" != "0" ]]; then
        del_conf_property ${TWITTER_INPUT_PATH} "proxy_address" || error_exit "Reconfiguration failed"
    fi
else
    if [[ "$(grep -c "proxy_address" "${TWITTER_INPUT_PATH}")" != "0" ]]; then
        replace_conf_value ${TWITTER_INPUT_PATH} "proxy_address" "\"$proxy_address\"" || error_exit "Reconfiguration failed"
    else
        add_conf_property ${TWITTER_INPUT_PATH} "proxy_address" "\"$proxy_address\"" || error_exit "Reconfiguration failed"
    fi
fi

# Configure proxy_port property
if [[ ${use_proxy} == "false" ]]; then
    # if use_proxy is set to false and proxy_port property exists in config file, delete it
    if [[ "$(grep -c "proxy_port" "${TWITTER_INPUT_PATH}")" != "0" ]]; then
        del_conf_property ${TWITTER_INPUT_PATH} "proxy_port" || error_exit "Reconfiguration failed"
    fi
else
    if [[ "$(grep -c "proxy_port" "${TWITTER_INPUT_PATH}")" != "0" ]]; then
        replace_conf_value ${TWITTER_INPUT_PATH} "proxy_port" $proxy_port || error_exit "Reconfiguration failed"
    else
        add_conf_property ${TWITTER_INPUT_PATH} "proxy_port" $proxy_port || error_exit "Reconfiguration failed"
    fi
fi

send_sighup_ifneeded

log end