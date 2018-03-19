#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


set -e

source ${utils_scripts}/utils.sh
# To set KIBANA_VERSION
source ${YSTIA_DIR}/kibana_env.sh

bash ${utils_scripts}/install-components.sh unzip

log info "Installing beats dashboards from ${dashboards_zip}"

tmpdir=$(mktemp -d)

unzip ${dashboards_zip} -d ${tmpdir}


log info "Loading beats dashboards (version ${KIBANA_VERSION})..."

if [[ "${KIBANA_VERSION}" = "6.2.2" ]]
then
    DB6_DIR=${tmpdir}/${KIBANA_VERSION}
    for JSON_FILE in $(find ${DB6_DIR}/index-pattern ${DB6_DIR}/dashboard)
    do
        curl -XPOST "http://localhost:5601/api/kibana/dashboards/import" -H 'Content-type:application/json' -H 'kbn-xsrf:true' -d@${JSON_FILE}
    done

    log info "Beats dashboards loaded."
elif [[ "${KIBANA_VERSION}" = "5.6.8" ]]
then
    cd $(dirname $(find ${tmpdir} -name "import_dashboards"))
    chmod u+x import_dashboards

    ./import_dashboards -dir packetbeat/
    ./import_dashboards -dir metricbeat/

    log info "Beats dashboards loaded."
else
    log info "WARNING: Beats dashboards CANNOT BE LOADED, unknown version ${KIBANA_VERSION} !!!"
fi

