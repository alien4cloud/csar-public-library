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

curl -XPOST http://localhost:5601/api/kibana/dashboards/import -H 'Content-type:application/json' -H 'kbn-xsrf:true' -d@${DASHBOARD_FILE}

log end
