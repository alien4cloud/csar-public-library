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
#https://github.com/chenryn/kbn_sankey_vis/tree/kibana5
SANKEY_VERSION="55aae65"
SANKEY_ZIP_NAME="kbn_sankey_vis-${SANKEY_VERSION}.zip"
#https://github.com/dlumbrer/kbn_network
NETWORK_VERSION="3bfc88d"
NETWORK_ZIP_NAME="kbn_network-${NETWORK_VERSION}.zip"
#https://github.com/snuids/heatmap
HEATMAP_VERSION="f9e4961"
HEATMAP_ZIP_NAME="kbn_heatmap-${HEATMAP_VERSION}.zip"
#https://github.com/raystorm-place/kibana-slider-plugin/pull/12
SLIDER_VERSION="ef68bc7"
SLIDER_ZIP_NAME="kbn_slider-${SLIDER_VERSION}.zip"
#https://github.com/mstoyano/kbn_c3js_vis
C3_CHARTS_VERSION="62194ef"
C3_CHARTS_ZIP_NAME="kbn_c3_charts-${C3_CHARTS_VERSION}.zip"
#https://github.com/clamarque/Kibana_health_metric_vis
HEALTH_METRIC_VERSION="f95effe"
HEALTH_METRIC_ZIP_NAME="kbn_health_metric-${HEALTH_METRIC_VERSION}.zip"
#https://github.com/fermiumlabs/mathlion/releases/tag/v0.2.3
MATHLION_VERSION="0.2.3"
MATHLION_ZIP_NAME="kbn_mathlion-${MATHLION_VERSION}.zip"
#https://github.com/prelert/kibana-swimlane-vis
SWIMLANE_VERSION="020bf27"
SWIMLANE_ZIP_NAME="kbn_swimlane-${SWIMLANE_VERSION}.zip"


#Install dependencies
sudo yum -y install unzip wget

# Kibana installation
log info "Installing Kibana on ${KIBANA_HOME_DIR}"
( cd ${INSTALL_DIR} && wget ${KBN_DOWNLOAD_PATH} ) || error_exit "ERROR: Failed to install Kibana (download problem) !!!"
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

# Sankey plugin installation
install_plugin "Sankey" ${SANKEY_ZIP_NAME}

# Network plugin installation
install_plugin "Network" ${NETWORK_ZIP_NAME}

# Heatmap plugin installation
install_plugin "Heatmap" ${HEATMAP_ZIP_NAME}

# Slider plugin installation
install_plugin "Slider" ${SLIDER_ZIP_NAME}

# C3 Charts plugin installation
install_plugin "C3_Charts" ${C3_CHARTS_ZIP_NAME}

# Health Metric plugin installation
install_plugin "Health_Metric" ${HEALTH_METRIC_ZIP_NAME}

# Mathlion plugin installation
install_plugin "Mathlion" ${MATHLION_ZIP_NAME}

# Swimlane plugin installation
install_plugin "SwimLane" ${SWIMLANE_ZIP_NAME}

# Installation end
setServiceInstalled
log end "Kibana successfully installed"
