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

log info "Stopping Kibana..."
sudo systemctl stop kibana.service

if [[ ! -z "${ELASTICSEARCH_HOME}" ]]
then
    sudo systemctl stop elasticsearch.service
fi

log end
