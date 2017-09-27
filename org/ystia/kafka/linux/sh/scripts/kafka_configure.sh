#!/usr/bin/env bash

# Script env variables
# NODE: Current component name (used to resolve environement file)
# IP_ADDRESS: Address used to register kafka services

source ${utils_scripts}/utils.sh
log begin

source ${consul_utils}/utils.sh

ensure_home_var_is_set

if isServiceConfigured; then
    log info "Kafka component '${NODE}' already configured"
    exit 0
fi

# Check JAVA_HOME, KAFKA_HOME, ... are set
[ -z ${JAVA_HOME} ] && error_exit "JAVA_HOME not set"
[ -z ${KAFKA_HOME} ] && error_exit "KAFKA_HOME not set"

# Setup systemd zookeeper service
sudo cp ${scripts}/systemd/zookeeper.service /etc/systemd/system/zookeeper.service
sudo sed -i -e "s/%USER%/${USER}/g" -e "s@%KAFKA_HOME%@${KAFKA_HOME}@g" -e "s@%JAVA_HOME%@${JAVA_HOME}@g" -e "s/%ZK_HEAP_SIZE%/${ZK_HEAP_SIZE}/g" /etc/systemd/system/zookeeper.service
sudo systemctl daemon-reload
#sudo systemctl enable zookeeper.service

# Setup systemd kafka service
sudo cp ${scripts}/systemd/kafka.service /etc/systemd/system/kafka.service
sudo sed -i -e "s/%USER%/${USER}/g" -e "s@%KAFKA_HOME%@${KAFKA_HOME}@g" -e "s@%JAVA_HOME%@${JAVA_HOME}@g" -e "s/%KF_HEAP_SIZE%/${KF_HEAP_SIZE}/g" /etc/systemd/system/kafka.service
sudo systemctl daemon-reload
#sudo systemctl enable kafka.service

DATA_DIR="/tmp"
if [[ -e "${STARLINGS_DIR}/.${NODE}-volumeFlag" ]]; then
    DATA_DIR=$(cat ${STARLINGS_DIR}/${NODE}-service.env | grep "^DATA_DIR" | cut -d '=' -f 2)
    log info "Kafka component '${NODE}' connected to a volume mounted on '${DATA_DIR}'"
    # If restarting on an non-empty volume get our id from the zookeeper stored id
    if [[ -e ${DATA_DIR}/zookeeper/myid ]]; then
        INSTANCE_ID=$(cat ${DATA_DIR}/zookeeper/myid | head -1)
        log info "Previous instance id found in data stored on persistent volume '${INSTANCE_ID}'"
    fi
else
    log info "No volume for kafka ; use /tmp as DATA_DIR"
    echo "DATA_DIR=${DATA_DIR}" >> ${STARLINGS_DIR}/${NODE}-service.env
fi

# For first deployments get a new id
if [[ -z "${INSTANCE_ID}" ]]; then
    log info "No previous instance id. Will use Consul to get a new one"
    INSTANCE_ID=$(get_new_id "service/kafka" "retry")
    log info "Instance id is '${INSTANCE_ID}'"
fi

#if [[ "$(type -t ctx > /dev/null | echo $?)" -eq 0 ]]; then
#  kafkaServiceName="kafka-$(ctx node properties application_name)"
#  kafkaZKServiceName="kafka-zk-$(ctx node properties application_name)"
#else
  KAFKA_SRV_NAME="kafka"
  KAFKA_ZK_SRV_NAME="kafka-zk"
#fi

KAFKA_BASE_DNS_SRV_NAME="${KAFKA_SRV_NAME}.service.starlings"
KAFKA_DNS_SRV_NAME="${INSTANCE_ID}.${KAFKA_BASE_DNS_SRV_NAME}"
KAFKA_ZK_BASE_DNS_SRV_NAME="${KAFKA_ZK_SRV_NAME}.service.starlings"
KAFKA_ZK_DNS_SRV_NAME="${INSTANCE_ID}.${KAFKA_ZK_BASE_DNS_SRV_NAME}"

log info "Kafka IP = ${IP_ADDRESS}"
log info "Kafka HostName = ${KAFKA_DNS_SRV_NAME}"

cat >> "${STARLINGS_DIR}/${NODE}-service.env" << EOF
INSTANCE_ID=${INSTANCE_ID}
KAFKA_SRV_NAME=${KAFKA_SRV_NAME}
KAFKA_BASE_DNS_SRV_NAME=${KAFKA_BASE_DNS_SRV_NAME}
KAFKA_DNS_SRV_NAME=${KAFKA_DNS_SRV_NAME}
KAFKA_ZK_SRV_NAME=${KAFKA_ZK_SRV_NAME}
KAFKA_ZK_BASE_DNS_SRV_NAME=${KAFKA_ZK_BASE_DNS_SRV_NAME}
KAFKA_ZK_DNS_SRV_NAME=${KAFKA_ZK_DNS_SRV_NAME}
KAFKA_JAVA_HOST=${HOST}
EOF

register_consul_service=${consul_utils}/register-consul-service.py
chmod +x ${register_consul_service}
${register_consul_service} -s ${KAFKA_SRV_NAME} -p 9092 -a ${IP_ADDRESS} -t ${INSTANCE_ID}
${register_consul_service} -s ${KAFKA_ZK_SRV_NAME} -p 2181 -a ${IP_ADDRESS} -t ${INSTANCE_ID}

export NB_INSTANCES=$(echo ${INSTANCES} | tr ',' '\n' | wc -l)
if [[ ${NB_INSTANCES} -gt 1 ]]; then
    . ${scripts}/generate_cluster_config.sh
fi

kafka_conf=${KAFKA_HOME}/config/server.properties
zk_conf=${KAFKA_HOME}/config/zookeeper.properties


#
# Updates a configuration option (comment it out if already defined)
# params:
#   1- attribute name
#   2- attribute value
#   3- file to update
update_config_option () {
    # first comment out explicit auto topic creation parameter if any
    sed -i -e "s/^\s*${1}=/#&/g" ${3}
    # then explicitly set it to selected value
    echo "${1}=${2}" >> ${3}
}

cp ${scripts}/templates/java.security ${KAFKA_HOME}/config
cp ${scripts}/templates/kafka-log4j.properties ${KAFKA_HOME}/config
cp ${scripts}/templates/zookeeper-log4j.properties ${KAFKA_HOME}/config

update_config_option "broker.id" "${INSTANCE_ID}" ${kafka_conf}

update_config_option "auto.create.topics.enable" "false" ${kafka_conf}
# Disable the automatic broker id generation feature as we are resolving this via Consul
update_config_option "broker.id.generation.enable" "false" ${kafka_conf}
update_config_option "advertised.host.name" "${KAFKA_DNS_SRV_NAME}" ${kafka_conf}

update_config_option "log.cleaner.enable" "${LOG_CLEANER_ENABLE}" ${kafka_conf}

if [[ ! -z "${DATA_DIR}" ]]
then
    update_config_option "dataDir" "${DATA_DIR}/zookeeper" ${zk_conf}
    update_config_option "log.dirs" "${DATA_DIR}/kafka-logs" ${kafka_conf}
fi

setServiceConfigured
log end