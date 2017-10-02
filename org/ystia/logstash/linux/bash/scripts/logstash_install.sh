#!/usr/bin/env bash

source ${utils_scripts}/utils.sh
log begin

ensure_home_var_is_set

if isServiceInstalled; then
    log end "Logstash component '${NODE}' already installed"
    exit 0
fi

LS_ZIP_NAME="logstash-${LS_VERSION}.tar.gz"
LS_DOWNLOAD_PATH="${REPOSITORY}/${LS_ZIP_NAME}"
export LOGSTASH_HOME=$HOME/logstash-${LS_VERSION}
log info "Environment variables : source is ${scripts} - home is ${HOME}"

# Install dependencies
bash ${utils_scripts}/install-components.sh "wget" || error_exit "ERROR: Failed to install wget"

log info "Downloading logstash ${LS_VERSION} from ${LS_DOWNLOAD_PATH} ..."
wget -O $HOME/${LS_ZIP_NAME} "${LS_DOWNLOAD_PATH}"
log info "Downloaded to $HOME/${LS_ZIP_NAME}"

log info "Extract $HOME/${LS_ZIP_NAME} to ${HOME}"
tar xzf $HOME/${LS_ZIP_NAME} -C ${HOME}

cd ${LOGSTASH_HOME}/bin
find -type f -name "*.sh" -exec chmod +x \{\} \;

setServiceInstalled
log end