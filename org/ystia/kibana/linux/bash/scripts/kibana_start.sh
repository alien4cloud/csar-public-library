#!/bin/bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source ${utils_scripts}/utils.sh

log begin

ensure_home_var_is_set

# To set KIBANA_HOME
source ${YSTIA_DIR}/kibana_env.sh

log info "Starting Kibana..."

sudo systemctl start kibana.service

sleep 3
wait_for_port_to_be_open "127.0.0.1" "5601" 240 || error_exit "Cannot open port 5601"
if [[ ! -z "${ELASTICSEARCH_HOME}" ]]
then
    wait_for_port_to_be_open 127.0.0.1 9200 120 10 || error_exit "Unable to start the ElasticSearch Client Node"
fi

log end
