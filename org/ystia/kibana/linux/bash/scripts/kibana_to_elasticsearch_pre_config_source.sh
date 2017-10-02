#!/usr/bin/env bash

source ${utils_scripts}/utils.sh

log begin

ensure_home_var_is_set

log debug "$0: Target: ${TARGET_NODE}/${TARGET_INSTANCE} and Source ${SOURCE_NODE}/${SOURCE_INSTANCE}"
log debug "$0: kibanaIp=${kibanaIp} and elasticsearchIp=${elasticsearchIp}"

# If Kibana and Elasticsearch are on same host, Elasticsearch client node is not necessary
[[ "${kibanaIp}" = "${elasticsearchIp}" ]] && log info "$0: Not needed to install an elasticsearch client node for kibana" && exit 0

#
# Elasticsearch installation
#
ES_ZIP_NAME="elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz"
ES_DOWNLOAD_PATH="${ELASTICSEARCH_REPOSITORY}/${ES_ZIP_NAME}"
ES_HASH_DOWNLOAD_PATH="${ES_DOWNLOAD_PATH}.sha1.txt"
ES_INSTALL_DIR=${HOME}
ES_UNZIP_FOLDER="elasticsearch-${ELASTICSEARCH_VERSION}"
ES_HOME_DIR=${ES_INSTALL_DIR}/${ES_UNZIP_FOLDER}

log info "Installing Elasticsearch on ${ES_HOME_DIR}"

echo "ELASTICSEARCH_HOME=${ES_HOME_DIR}" >>${YSTIA_DIR}/kibana_env.sh

# Install dependencies
bash ${utils_scripts}/install-components.sh "wget" || error_exit "ERROR: Failed to install wget"

# Elasticsearch installation
( cd ${ES_INSTALL_DIR} && wget ${ES_DOWNLOAD_PATH} ) || error_exit "ERROR: Failed to install Elasticsearch (download problem) !!!"
tar -xzf ${ES_INSTALL_DIR}/${ES_ZIP_NAME} -C ${ES_INSTALL_DIR} || error_exit "ERROR: Failed to install Elasticsearch (untar problem) !!!"

log end