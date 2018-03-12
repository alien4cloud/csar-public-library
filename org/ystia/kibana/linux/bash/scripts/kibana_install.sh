#!/bin/bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source ${utils_scripts}/utils.sh
log begin

# To set variables for the proxy
ensure_home_var_is_set

if isServiceInstalled; then
    log end "Kibana component '${NODE}' already installed"
    exit 0
fi

KBN_ZIP_NAME="kibana-${KBN_VERSION}-linux-x86_64.tar.gz"
KBN_DOWNLOAD_PATH="${REPOSITORY}/${KBN_ZIP_NAME}"
KBN_UNZIP_FOLDER="kibana-${KBN_VERSION}-linux-x86_64"
INSTALL_DIR=${HOME}
KIBANA_HOME_DIR=${INSTALL_DIR}/${KBN_UNZIP_FOLDER}

echo "KIBANA_HOME=${KIBANA_HOME_DIR}" >${YSTIA_DIR}/kibana_env.sh

KIBANA_PLUGIN_DIR=${KIBANA_HOME_DIR}/plugins

if [[ $(majorVersion ${KBN_VERSION}) == 6 ]]
then
    NETWORK_VERSION="v6_2017_12_14"
    HEALTH_METRIC_VERSION="6.2.2"
    SWIMLANE_VERSION="6.2.2"
else
    NETWORK_VERSION="v56_2017_10_27_patched"
fi
#https://github.com/dlumbrer/kbn_network
NETWORK_ZIP_NAME="kbn_network_vis-${NETWORK_VERSION}.zip"
#https://github.com/clamarque/Kibana_health_metric_vis
HEALTH_METRIC_ZIP_NAME="kbn_health_metric_vis-${HEALTH_METRIC_VERSION}.zip"
#https://github.com/prelert/kibana-swimlane-vis
SWIMLANE_ZIP_NAME="kbn_swimlane_vis-${SWIMLANE_VERSION}.zip"


#Install dependencies
sudo yum -y install unzip wget

# Kibana installation
log info "Installing Kibana on ${KIBANA_HOME_DIR}"
( cd ${INSTALL_DIR} && wget ${KBN_DOWNLOAD_PATH} ) || error_exit "ERROR: Failed to install Kibana (download problem) !!!"
if [[ $(majorVersion ${KBN_VERSION}) == 6 ]]
then
    wget ${KBN_DOWNLOAD_PATH}.sha512 -O ${HOME}/${KBN_ZIP_NAME}.sha512
    (cd ${HOME}; sha512sum -c ${KBN_ZIP_NAME}.sha512) || error_exit "ERROR: Checksum validation failed for downloaded Kibana binary"
else
    wget ${KBN_DOWNLOAD_PATH}.sha1 -O ${HOME}/${KBN_ZIP_NAME}.sha1
    (cd ${HOME}; echo "$(cat ${KBN_ZIP_NAME}.sha1) ${KBN_ZIP_NAME}" | sha1sum -c) || error_exit "ERROR: Checksum validation failed for downloaded Kibana binary"
fi
tar -xzf ${INSTALL_DIR}/${KBN_ZIP_NAME} -C  ${INSTALL_DIR} || error_exit "ERROR: Failed to install Kibana (untar problem) !!!"


#
# Kibana plugins installation
#

# args:
# $1 :plugin name
# $2 :plugin zip name
function install_plugin {
    log info ">>>> Install ${1} plugin"
    sudo cp ${plugins}/${2} ${KIBANA_PLUGIN_DIR}
    sudo unzip ${KIBANA_PLUGIN_DIR}/${2} -d ${KIBANA_PLUGIN_DIR}
}

# Network plugin installation
install_plugin "Network" ${NETWORK_ZIP_NAME}
if [[ $(majorVersion ${KBN_VERSION}) == 6 ]]
then
    # Health Metric plugin installation
    install_plugin "Health_Metric" ${HEALTH_METRIC_ZIP_NAME}
    # Swimlane plugin installation
    install_plugin "SwimLane" ${SWIMLANE_ZIP_NAME}
fi


# Installation end
setServiceInstalled
log end "Kibana successfully installed"
