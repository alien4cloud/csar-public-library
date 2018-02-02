#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#

source ${utils_scripts}/utils.sh

log begin

ES_HOME="$HOME/elasticsearch-${ES_VERSION}"
source ${scripts}/es_utils.sh

update_property "path.data" "${path_fs}"

log end