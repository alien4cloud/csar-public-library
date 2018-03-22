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

if [[ -e "${YSTIA_DIR}/.${SOURCE_NODE}-postconfigureElasticsearchFlag" ]]; then
    log info "Component '${SOURCE_NODE}' already configured to work with elasticsearch"
    exit 0
fi
install_dir=${HOME}/${SOURCE_NODE}
config_file=${install_dir}/*beat.yml
template_file=$(ls ${install_dir}/*beat.template.json 2> /dev/null | head -1)

#uncomment elasticsearch output
sudo sed -i "s/#output.elasticsearch/output.elasticsearch/g" ${config_file}

# If we can resolve ES using consul lets use this address otherwise assume that ES is running locally
elastic_host="localhost"
if host elasticsearch.service.ystia > /dev/null 2>&1 ; then
    elastic_host="elasticsearch.service.ystia"
fi

if [[ "$(sudo grep -c "#ELASTIC_SEARCH_OUTPUT_PLACEHOLDER#" ${config_file})" != "0" ]]; then
    beatname=${template_file##*/}
    beatname=${beatname%%.*}
    es_output='  \
    # Array of hosts to connect to.\
    # Scheme and port can be left out and will be set to the default (http and 9200)\
    hosts: ["'"${elastic_host}"'"]'
    if [[ -f ${template_file} && $(majorVersion ${BT_VERSION}) == 5 ]] ; then
        # By default, Beat version 6, automatically loads the recommended template file, fields.yml, if the Elasticsearch output is enabled.
         es_output="${es_output}"'\
    template:\
      name: "'"${beatname}"'"\
      path: "'"${template_file}"'"\
      overwrite: true'
    fi
    sudo sed -i -e '/#ELASTIC_SEARCH_OUTPUT_PLACEHOLDER#/ a \
'"${es_output}" ${config_file}
fi



touch ${YSTIA_DIR}/.${SOURCE_NODE}-postconfigureElasticsearchFlag
log end
