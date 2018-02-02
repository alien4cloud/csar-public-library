#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


set -e

source ${utils_scripts}/utils.sh

bash ${utils_scripts}/install-components.sh unzip

log info "Installing beats dashboards from ${dashboards_zip}"

tmpdir=$(mktemp -d)

unzip ${dashboards_zip} -d ${tmpdir}

cd $(dirname $(find ${tmpdir} -name "import_*_dashboards"))

log info "Loading beats dashboards..."

chmod u+x import_metricbeat_dashboards
chmod u+x import_packetbeat_dashboards

./import_packetbeat_dashboards -dir packetbeat/
./import_metricbeat_dashboards -dir metricbeat/

log info "Beats dashboards loaded."
