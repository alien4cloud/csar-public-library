#!/usr/bin/env bash

source ${utils_scripts}/utils.sh
log begin

ensure_home_var_is_set

if isServiceInstalled; then
    log info "Kafka component '${NODE}' already installed"
    exit 0
fi

zipName="kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"
downloadPath="${REPOSITORY}/kafka/${KAFKA_VERSION}/${zipName}"
installDir="${HOME}/kafka"
KAFKA_HOME="${installDir}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}"

# Install dependencies
#   - jq for json parsing
#   - netcat for network utility using TCP/IP protocol
bash ${utils_scripts}/install-components.sh jq

declare -A packages_names=( ["centos"]="nc" ["ubuntu"]="netcat" )
os_distribution="$(get_os_distribution)"
bash ${utils_scripts}/install-components.sh ${packages_names["${os_distribution}"]} || error_exit "ERROR: Failed to install netcat (install-components.sh ${packages_names["${os_distribution}"]} problem) !!!"
bash ${utils_scripts}/install-components.sh "wget" || error_exit "ERROR: Failed to install wget"

mkdir -p ${installDir}
log info  "Downloading $downloadPath"
wget "${downloadPath}" -P "${installDir}" -N

tar xzf ${installDir}/${zipName} -C ${installDir}
chmod +x ${KAFKA_HOME}/bin/*
# TODO cp ${scripts}/patches/zookeeper-3.4.6.jar ${KAFKA_HOME}/libs/zookeeper-3.4.6.jar

setServiceInstalled

log end
