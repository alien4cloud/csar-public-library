#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source ${utils_scripts}/utils.sh
log begin

ensure_home_var_is_set

log info "NiFi Download URL = $NIFI_DEFAULT_URL"

if isServiceInstalled; then
    log info "NiFi component '${NODE}' already installed"
    exit 0
fi


bash ${utils_scripts}/install-components.sh "wget" || error_exit "ERROR: Failed to install wget"
bash ${utils_scripts}/install-components.sh "unzip" || error_exit "ERROR: Failed to install unzip"

#TODO HJo
set -x

# To avoid '~/nifi' and convert it with /home/cloud-user/nifi for example
NIFI_INSTALL_DIR2=$(echo ${NIFI_INSTALL_DIR} |sed -e "s|^'||" | sed -e "s|'$||" |sed -e "s|~|$HOME|")

NIFI_ZIP_NAME="nifi-${NIFI_VERSION}-bin.zip"
NIFI_DOWNLOAD_PATH="${REPOSITORY}/${NIFI_ZIP_NAME}"
mkdir -p ${NIFI_INSTALL_DIR2}
log info "Downloading ${NIFI_DOWNLOAD_PATH} ..."
wget ${NIFI_DOWNLOAD_PATH} -P ${NIFI_INSTALL_DIR2}

log info "Installing NIFI on ${NIFI_INSTALL_DIR2} ..."
unzip ${NIFI_INSTALL_DIR2}/*.zip -d ${NIFI_INSTALL_DIR2}
rm ${NIFI_INSTALL_DIR2}/*.zip
mv ${NIFI_INSTALL_DIR2}/*/* ${NIFI_INSTALL_DIR2}

export NIFI_HOME=${NIFI_INSTALL_DIR2}

# Add the twitter_proxy_collector to nifi
cp ${scripts}/processors/*.nar ${NIFI_HOME}/lib

log info "NiFi downloaded and installed in ${NIFI_HOME} successfully."

setServiceInstalled
log end

