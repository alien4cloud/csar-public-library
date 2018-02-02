#!/bin/bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


DASHBOARD_FILE=$1

source ${utils_scripts}/utils.sh
log begin
ensure_home_var_is_set
source ${YSTIA_DIR}/kibana_env.sh

ELASTICSEARCH_URL="http://localhost:9200"
KIBANA_INDEX=".kibana"


# Workaround to solve the mapping problem (long instead int) for the fields 'hits' and 'version' to fix the discovery problem
curl -XPUT "${ELASTICSEARCH_URL}/${KIBANA_INDEX}"
curl -XPUT "${ELASTICSEARCH_URL}/${KIBANA_INDEX}/_mapping/search" -d'{"search": {"properties": {"hits": {"type": "integer"}, "version": {"type": "integer"}}}}'
curl -XPUT "${ELASTICSEARCH_URL}/${KIBANA_INDEX}/_mapping/visualization" -d'{"visualization": {"properties": {"hits": {"type": "integer"}, "version": {"type": "integer"}}}}'
curl -XPUT "${ELASTICSEARCH_URL}/${KIBANA_INDEX}/_mapping/dashboard" -d'{"dashboard": {"properties": {"hits": {"type": "integer"}, "version": {"type": "integer"}}}}'


CMD="python2 ${scripts}/ystia_import_dashboard.py -f ${DASHBOARD_FILE} -es ${ELASTICSEARCH_URL} -k ${KIBANA_INDEX}"
log info "$CMD"
$CMD

log end
