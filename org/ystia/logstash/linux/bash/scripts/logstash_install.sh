#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#

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
echo "LOGSTASH_HOME=${LOGSTASH_HOME}" > ${YSTIA_DIR}/${NODE}-service.env
log info "Environment variables : source is ${scripts} - home is ${HOME}"

# Install dependencies
bash ${utils_scripts}/install-components.sh "wget" || error_exit "ERROR: Failed to install wget"

log info "Downloading logstash ${LS_VERSION} from ${LS_DOWNLOAD_PATH} ..."
wget -O $HOME/${LS_ZIP_NAME} "${LS_DOWNLOAD_PATH}"
if [[ $(majorVersion ${LS_VERSION}) == 6 ]]
then
    wget ${LS_DOWNLOAD_PATH}.sha512 -O ${HOME}/${LS_ZIP_NAME}.sha512
    (cd ${HOME}; sha512sum -c ${LS_ZIP_NAME}.sha512) || error_exit "ERROR: Checksum validation failed for downloaded Logstash binary"
else
    wget ${LS_DOWNLOAD_PATH}.sha1 -O ${HOME}/${LS_ZIP_NAME}.sha1
    (cd ${HOME}; echo "$(cat ${LS_ZIP_NAME}.sha1) ${LS_ZIP_NAME}" | sha1sum -c) || error_exit "ERROR: Checksum validation failed for downloaded Logstash binary"
fi
log info "Downloaded to $HOME/${LS_ZIP_NAME}"

log info "Extract $HOME/${LS_ZIP_NAME} to ${HOME}"
tar xzf $HOME/${LS_ZIP_NAME} -C ${HOME}

cd ${LOGSTASH_HOME}/bin
find -type f -name "*.sh" -exec chmod +x \{\} \;

setServiceInstalled
log end