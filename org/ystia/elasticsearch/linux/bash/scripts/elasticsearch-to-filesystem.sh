#!/usr/bin/env bash

source ${utils_scripts}/utils.sh

log begin

ES_HOME="$HOME/elasticsearch-${ES_VERSION}"
source ${scripts}/es_utils.sh

update_property "path.data" "${path_fs}"

log end