#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#

source ${utils_scripts}/utils.sh
source ${scripts}/cloudera.properties
log begin

# To set variables for the proxy
ensure_home_var_is_set

if isServiceInstalled; then
    log end "Cloudera Server component '${NODE}' already installed"
    exit 0
fi

if [[ -z "${CLOUDERA_MANAGER_REPO}" ]] || [[ "${CLOUDERA_MANAGER_REPO}" == "DEFAULT" ]] || [[ "${CLOUDERA_MANAGER_REPO}" == "null" ]]; then
    CLOUDERA_MANAGER_REPO=${CLOUDERA_MANAGER_DEFAULT_REPO}
fi

source ${scripts}/prepare_host.sh

log info "Cloudera Server repository is ${CLOUDERA_MANAGER_REPO}"

log info "Building yum repo file"
cat ${data}/cloudera-manager.repo |
sed "s|@CLOUDERA_MANAGER_REPO@|${CLOUDERA_MANAGER_REPO}|g" >/tmp/cloudera-manager.repo
sudo cp /tmp/cloudera-manager.repo /etc/yum.repos.d

log info "Installing JDK, Embedded PostgreSQL Database and Cloudera Manager Server"
bash ${utils_scripts}/install-components.sh "oracle-j2sdk1.7 cloudera-manager-server-db-2 cloudera-manager-daemons cloudera-manager-server"

setServiceInstalled
log end

