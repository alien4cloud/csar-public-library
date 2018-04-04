#!/usr/bin/env bash
#
# Starlings
# Copyright (C) 2016 Bull S.A.S. - All rights reserved
#

source ${utils_scripts}/utils.sh
source ${scripts}/cloudera.properties
log begin

# To set variables for the proxy
ensure_home_var_is_set

if isServiceInstalled; then
    log end "Cloudera Agent component '${NODE}' already installed"
    exit 0
fi

if [[ -z "${CLOUDERA_MANAGER_REPO}" ]] || [[ "${CLOUDERA_MANAGER_REPO}" == "DEFAULT" ]] || [[ "${CLOUDERA_MANAGER_REPO}" == "null" ]]; then
    CLOUDERA_MANAGER_REPO=${CLOUDERA_MANAGER_DEFAULT_REPO}
fi

source ${scripts}/prepare_host.sh

source ${scripts}/cdh_install.sh

log info "Cloudera Agent repository is ${CLOUDERA_MANAGER_REPO}"

log info "Building yum repo file"
cat ${data}/cloudera-manager.repo |
sed "s|@CLOUDERA_MANAGER_REPO@|${CLOUDERA_MANAGER_REPO}|g" >/tmp/cloudera-manager.repo
sudo cp /tmp/cloudera-manager.repo /etc/yum.repos.d

log info "Installing JDK and Cloudera Manager Agent"
bash ${utils_scripts}/install-components.sh "oracle-j2sdk1.7 cloudera-manager-daemons cloudera-manager-agent"

setServiceInstalled
log end