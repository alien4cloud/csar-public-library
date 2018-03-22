#!/bin/bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source ${utils_scripts}/utils.sh
log begin

log info "On $(hostname) Updating Elasticsearch with nb_replicas '${nb_replicas}', index '${index}' and order '${order}'"

if [[ "${index}" != "" ]] && [[ "${index}" != "''" ]]; then
    TEMPLATE_NAME=$(echo "${index}" | sed 's/[^a-zA-Z0-9]//g')
else
    index="*"
    TEMPLATE_NAME="all"
fi

TEMPLATE_INDEX="http://localhost:9200/_template/${TEMPLATE_NAME}"
TEMPLATE_JSON_FILE=${YSTIA_DIR}/${NODE}-${TEMPLATE_NAME}.json
CURL='/usr/bin/curl'
OP='-XPUT'
cat > ${TEMPLATE_JSON_FILE} << EOF
{
  "template" : "${index}",
  "order" : ${order},
  "settings" : {
    "number_of_shards" : ${number_of_shards},
    "number_of_replicas" : ${nb_replicas}
  }
}
EOF
$CURL $OP -H 'Content-Type: application/json' $TEMPLATE_INDEX -d @${TEMPLATE_JSON_FILE} || error_exit "Failed executing Elasticsearch update with nb_replicas ${nb_replicas}, index ${index}and order ${order}" $?
log end
