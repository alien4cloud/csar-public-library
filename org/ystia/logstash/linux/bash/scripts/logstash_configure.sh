#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source ${utils_scripts}/utils.sh
log begin

ensure_home_var_is_set

if isServiceConfigured; then
    log end "Logstash component '${NODE}' already configured"
    exit 0
fi

# Check JAVA_HOME, LOGSTASH_HOME, ...
[ -z ${JAVA_HOME} ] && error_exit "JAVA_HOME not set"
[ -z ${LOGSTASH_HOME} ] && error_exit "LOGSTASH_HOME not set"

# Set environment variable used for systemd
# overload JAVACMD variable (used in the logstash scripts)
export JAVACMD="${JAVA_HOME}/bin/java"
JAVA_OPTS_2=$(echo ${JAVA_OPTS} |sed -s 's|-Xmx[0-9]*[a-zA-Z]||')
export JAVA_OPTS=${JAVA_OPTS_2}

export LOGSTASH_CMD_OPTS="--log.level ${LOGSTASH_LOG_LEVEL}"
if [[ "${AUTO_RELOAD}" == "true" ]]; then
    if [[ $(majorVersion ${LS_VERSION}) == 6 ]]
    then
        RELOAD_INTERVAL=${RELOAD_INTERVAL}s
    fi
    log info "Logstash configuration : auto_reload is set and reload_interval is ${RELOAD_INTERVAL}"
    export LOGSTASH_CMD_OPTS="--config.reload.automatic --config.reload.interval ${RELOAD_INTERVAL} ${LOGSTASH_CMD_OPTS}"
fi

# Setup systemd service
sudo cp ${scripts}/systemd/logstash.service /etc/systemd/system/logstash.service
sudo sed -i -e "s/%USER%/${USER}/g" -e "s@%LOGSTASH_HOME%@${LOGSTASH_HOME}@g" -e "s@%JAVA_HOME%@${JAVA_HOME}@g" -e "s/%JAVA_OPTS%/${JAVA_OPTS}/g" -e "s/%LOGSTASH_CMD_OPTS%/${LOGSTASH_CMD_OPTS}/g" /etc/systemd/system/logstash.service
sudo systemctl daemon-reload
#sudo systemctl enable logstash.service


mkdir -p "${LOGSTASH_HOME}/conf"
mkdir -p "${LOGSTASH_HOME}/logs"
mkdir -p "${LOGSTASH_HOME}/lib/logstash/certs"
mkdir -p "${LOGSTASH_HOME}/patterns"

# Set JVM heap size via jvm.options
CONFIG_PATH=${LOGSTASH_HOME}/config
JVM_OPTIONS_FILE=${CONFIG_PATH}/jvm.options
sed -i -e "s/^-Xms.*$/-Xms${LOGSTASH_HEAP_SIZE}/g" -e "s/^-Xmx.*$/-Xmx${LOGSTASH_HEAP_SIZE}/g" ${JVM_OPTIONS_FILE}

if [[ "${STDOUT}" = "true" ]]
then
    # A new output config file is added in case STDOUT is true.
     log info "Configure stdout for logstash"
     cp ${conf}/3-stdout_logstash_outputs.conf $LOGSTASH_HOME/conf
else
     log info "Configure logstash without stdout"
     rm -f $LOGSTASH_HOME/conf/3-stdout_logstash_outputs.conf
fi

log info "Copy configuration files and certificates..."

cp "${inputs_conf}" "${LOGSTASH_HOME}/conf/1-1_logstash_inputs.conf"
cp "${filters_conf}" "${LOGSTASH_HOME}/conf/2-1_logstash_filters.conf"
cp "${outputs_conf}" "${LOGSTASH_HOME}/conf/3-1_logstash_outputs.conf"

cp "${scripts}/files/java.security" "${LOGSTASH_HOME}/java.security"
cp "${scripts}/files/logback" "${LOGSTASH_HOME}/patterns/logback"

cp ${certificates}/* "${LOGSTASH_HOME}/lib/logstash/certs"
cp "${private_key}" "${LOGSTASH_HOME}/lib/logstash/certs/default-logstash-forwarder.key"
cp "${certificate}" "${LOGSTASH_HOME}/lib/logstash/certs/default-logstash-forwarder.crt"

sed -i -e "s@#LOGSTASH_CERTIFICATES_DIR#@${LOGSTASH_HOME}/lib/logstash/certs@g" ${LOGSTASH_HOME}/conf/*

# For multiple level LKEK purpose only, add /etc/hosts with name's of kafka n+1 level find into artifacts extra_host
#sudo bash -c "cat ${extra_host} >>/etc/hosts"
#echo `date` ">>>> 'extra_hosts' added in '/etc/hosts'"

setServiceConfigured

log end
