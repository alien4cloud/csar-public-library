#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#



source ${utils_scripts}/utils.sh

log begin

ensure_home_var_is_set
lock "$(basename $0)"
# Ensure that we will release the lock whatever may happen
trap "unlock $(basename $0)" EXIT

if [[ -e "${YSTIA_DIR}/.${SOURCE_NODE}-postconfigureLogstashFlag" ]]; then
    log info "Component '${SOURCE_NODE}' already configured to work with Logstash"
    exit 0
fi
install_dir=${HOME}/${SOURCE_NODE}
config_file=${install_dir}/*beat.yml

#uncomment logstash output
sudo sed -i "s/#output.logstash/output.logstash/g" ${config_file}

if [[ "$(sudo grep -c "#LOGSTASH_OUTPUT_PLACEHOLDER#" ${config_file})" != "0" ]]; then
    sudo sed -i -e '/#LOGSTASH_OUTPUT_PLACEHOLDER#/ a \
    hosts: ["'"$(get_multi_instances_attribute "TARGET_IP_ADDRESS" "TARGET" | sed -e ':a;N;$!ba;s/\n/:5044","/g')"':5044"]\
    loadbalance: true' ${config_file}
fi

touch ${YSTIA_DIR}/.${SOURCE_NODE}-postconfigureLogstashFlag
log end
