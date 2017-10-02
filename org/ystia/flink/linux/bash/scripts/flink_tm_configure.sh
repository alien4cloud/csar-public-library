#!/usr/bin/env bash
#
# Starlings
# Copyright (C) 2016 Bull S.A.S. - All rights reserved
#

source ${utils_scripts}/utils.sh
source ${consul_utils}/utils.sh

log begin

ensure_home_var_is_set

if isServiceConfigured; then
    log info "Flink component '${NODE}' already configured"
    exit 0
fi

# Env file contains:
# FLINK_HOME: Flink installation path
source ${HOME}/.starlings/${NODE}-service.env

# Register the service in consul

# For first deployments get a new id
if [[ -z "${INSTANCE_ID}" ]]; then
    log info "No previous instance id. Will use Consul to get a new one"
    INSTANCE_ID="$(get_new_id service/flink-tm retry |tail -1)"
    log info "Instance id is '${INSTANCE_ID}'"
fi

FLK_TM_BASE_DNS_SERVICE_NAME="flink-tm.service.starlings"
FLK_JM_BASE_DNS_SERVICE_NAME="flink-jm.service.starlings"
FLK_TM_DNS_SERVICE_NAME="${INSTANCE_ID}.${FLK_TM_BASE_DNS_SERVICE_NAME}"

log info "Flink TaskManager IP = ${IP_ADDRESS}"
log info "Flink TaskManager HostName = ${FLK_TM_DNS_SERVICE_NAME}"

cat >> "${YSTIA_DIR}/${NODE}-service.env" << EOF
INSTANCE_ID=${INSTANCE_ID}
FLK_TM_BASE_DNS_SERVICE_NAME=${FLK_TM_BASE_DNS_SERVICE_NAME}
FLK_TM_DNS_SERVICE_NAME=${FLK_TM_DNS_SERVICE_NAME}
EOF

register_consul_service=${consul_utils}/register-consul-service.py
chmod +x ${register_consul_service}
log info "Register the service in consul: name=flink-tm, port=${TASKMANAGER_PORT}, address=${IP_ADDRESS}, tag=${INSTANCE_ID}"
${register_consul_service} -s flink-tm -a ${IP_ADDRESS} -t ${INSTANCE_ID}

#-p ${TASKMANAGER_PORT}

# Generate configuration

log info "Configure a Flink TaskManager"

sed -i "s@jobmanager.rpc.address: localhost@jobmanager.rpc.address: ${FLK_JM_BASE_DNS_SERVICE_NAME}@g" "${FLINK_HOME}/conf/flink-conf.yaml"
sed -i "s@taskmanager.heap.mb: 512@taskmanager.heap.mb: ${TASKMANAGER_MEM}@g" "${FLINK_HOME}/conf/flink-conf.yaml"
sed -i "s@taskmanager.numberOfTaskSlots: 1@taskmanager.numberOfTaskSlots: ${TASKMANAGER_SLOTS}@g" "${FLINK_HOME}/conf/flink-conf.yaml"
sed -i "s@parallelism.default: 1@parallelism.default: ${PARALLELISM_DEFAULT}@g" "${FLINK_HOME}/conf/flink-conf.yaml"
sed -i "s@# taskmanager.tmp.dirs: /tmp@taskmanager.tmp.dirs: ${TASKMANAGER_TMP_DIRS}@g" "${FLINK_HOME}/conf/flink-conf.yaml"

log info "Flink TaskManager configured to connects to JobManager ${FLK_TM_BASE_DNS_SERVICE_NAME}"

# Setup systemd service
sudo cp ${scripts}/systemd/flink-tm.service /etc/systemd/system/flink.service

sudo sed -i -e "s/{{USER}}/${USER}/g" -e "s@{{FLINK_HOME}}@${FLINK_HOME}@g" -e "s@{{JAVA_HOME}}@${JAVA_HOME}@g" -e "s@{{TASKMANAGER_MEM}}@${TASKMANAGER_MEM}@g" /etc/systemd/system/flink.service
sudo systemctl daemon-reload
#sudo systemctl enable flink.service


setServiceConfigured
log end