#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source ${utils_scripts}/utils.sh

ensure_home_var_is_set

log begin

source ${YSTIA_DIR}/${NODE}-service.env

if is_port_open "127.0.0.1" "8500"
then
    # Consul is present: distributed case
    OPTIONS='--noproxy .ystia'
    ES='0.elasticsearch.service.ystia'
else
    # No consul: local case.
    ES='localhost'
fi
log info "Command: curl $OPTIONS -XGET http://${ES}:9200/_cat/indices?v"

log end
