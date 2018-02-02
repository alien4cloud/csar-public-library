#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#

CONFIG_PATH=${ES_HOME}/config

comment_existing_property () {
    property_name=$1
    sed -i.bak -e "s/^\s*${property_name}:/#${property_name}:/g" ${CONFIG_PATH}/elasticsearch.yml
}

update_property () {
    property_name=$1
    property_value=$2
    if [[ ! -z "${property_value}" ]] && [[ "${property_value}" != "null" ]]
    then
        if [[ $(grep -c -E "^\s*${property_name}:" ${CONFIG_PATH}/elasticsearch.yml) -gt 1 ]]
        then
            comment_existing_property "${property_name}"
            echo "${property_name}: ${property_value}" >> ${CONFIG_PATH}/elasticsearch.yml
        else
            # replace only the first match
            sed -i -e "0,/^.*${property_name}:.*$/s##${property_name}: ${property_value}#" ${CONFIG_PATH}/elasticsearch.yml
        fi
    fi
}