#!/usr/bin/env bash

log begin

# Script env variables
# NODE: Current component name (used to resolve environement file)
# ZOOKEEPER_NODES: cluster ips in form: "<id1>.<server1> <id2>.<server2> ..."

# Env file contains:
# KAFKA_HOME: Kafka installation path
# INSTANCE_ID: id of this zookeeper instance
# DATA_DIR: directory were data should be stored (default location if empty)
# KAFKA_SRV_NAME: Name of the Kafka service as registered in consul
# KAFKA_BASE_DNS_SRV_NAME: Base DNS service name for Kafka service
# KAFKA_ZK_SRV_NAME: Name of the Kafka-Zookeeper service as registered in consul
# KAFKA_ZK_BASE_DNS_SRV_NAME: Base DNS service name for Kafka-Zookeeper service
source ${YSTIA_DIR}/${NODE}-service.env


if [[ -z "${DATA_DIR}" ]]
then
    ZK_DATA_PATH="/tmp/zookeeper"
else
    ZK_DATA_PATH="${DATA_DIR}/zookeeper"
fi


zk_conf_template="${scripts}/templates/zookeeper.properties"
zk_conf=${KAFKA_HOME}/config/zookeeper.properties
kafka_conf=${KAFKA_HOME}/config/server.properties

log info "Updating ZooKeeper configuration"
mv ${zk_conf} ${zk_conf}.bak

cp ${zk_conf_template} ${zk_conf}

found="false"
while [[ "${found}" == "false" ]] || [[ $(echo "${ZOOKEEPER_NODES}" | wc -l) -lt ${NB_INSTANCES} ]]; do
    ZOOKEEPER_NODES=$(curl -s http://127.0.0.1:8500/v1/catalog/service/${KAFKA_ZK_SRV_NAME} | jq -r '.[]|.ServiceTags[]')
    log debug "found following tags for zookeeper service: ${ZOOKEEPER_NODES}"
    if [[ $(echo "${ZOOKEEPER_NODES}" | wc -l) -ge ${NB_INSTANCES} ]]; then
        found="true"
    else
        log debug "At least one Zookeeper instance is not yet registered. Lets retry in few seconds."
        sleep 5
    fi
done

for server_id in ${ZOOKEEPER_NODES}
do
    #first part of the dns name is the instance id
    server="${server_id}.${KAFKA_ZK_BASE_DNS_SRV_NAME}"
    sed -i -e "/# ZooKeeper servers pool/ a\
server.${server_id}=${server}:2888:3888" ${zk_conf}
done

if [[ ! -e ${ZK_DATA_PATH}/myid ]]; then
    mkdir -p ${ZK_DATA_PATH}
    echo ${INSTANCE_ID} > ${ZK_DATA_PATH}/myid
fi

log info "Updating Kafka configuration"

sed -i -e "s/^zookeeper.connect=.*$/zookeeper.connect=${KAFKA_ZK_BASE_DNS_SRV_NAME}:2181/" ${kafka_conf}

log end "Cluster configuration done."
