#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source ${utils_scripts}/utils.sh
log begin

ensure_home_var_is_set

if isServiceConfigured; then
    log end "FileBeat component '${NODE}' already configured"
    exit 0
fi

install_dir=${HOME}/${NODE}
config_file=${install_dir}/filebeat.yml

if [[ "$(grep -c "#FILES_PLACEHOLDER#" ${config_file})" != "0" ]]; then
    sed -i -e '/#FILES_PLACEHOLDER#/ a \
        - '"$(echo "${FILES}"| sed -e 's/,/\\\n        - /')" ${config_file}
fi

setServiceConfigured
log end
