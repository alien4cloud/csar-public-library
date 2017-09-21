#!/usr/bin/env bash
#
# Starlings
# Copyright (C) 2016 Bull S.A.S. - All rights reserved
#

source ${utils_scripts}/utils.sh
source ${consul_utils}/utils.sh
source ${scripts}/flink-service.properties

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
    INSTANCE_ID="$(get_new_id service/${FLINK_JM_SERVICE_NAME} retry |tail -1)"
    log info "Instance id is '${INSTANCE_ID}'"
fi

FLK_BASE_DNS_SERVICE_NAME="${FLINK_JM_SERVICE_NAME}.service.starlings"
FLK_DNS_SERVICE_NAME="${INSTANCE_ID}.${FLK_BASE_DNS_SERVICE_NAME}"

log info "Flink JobManager IP = ${IP_ADDRESS}"
log info "Flink JobManager HostName = ${FLK_DNS_SERVICE_NAME}"

cat >> "${STARLINGS_DIR}/${NODE}-service.env" << EOF
INSTANCE_ID=${INSTANCE_ID}
FLINK_JM_SERVICE_NAME=${FLINK_JM_SERVICE_NAME}
FLK_BASE_DNS_SERVICE_NAME=${FLK_BASE_DNS_SERVICE_NAME}
FLK_DNS_SERVICE_NAME=${FLK_DNS_SERVICE_NAME}
EOF

register_consul_service=${consul_utils}/register-consul-service.py
chmod +x ${register_consul_service}
log info "Register the service in consul: name=${FLINK_JM_SERVICE_NAME}, port=${JOBMANAGER_PORT}, address=${IP_ADDRESS}, tag=${INSTANCE_ID}"
${register_consul_service} -s ${FLINK_JM_SERVICE_NAME} -p ${JOBMANAGER_PORT} -a ${IP_ADDRESS} -t ${INSTANCE_ID}

# Generate configuration

log info "Configure a flink JobManager"
sed -i "s@jobmanager.rpc.address: localhost@jobmanager.rpc.address: ${FLK_DNS_SERVICE_NAME}@g" "${FLINK_HOME}/conf/flink-conf.yaml"
sed -i "s@jobmanager.heap.mb: 256@jobmanager.heap.mb: ${JOBMANAGER_HEAP}@g" "${FLINK_HOME}/conf/flink-conf.yaml"

# Setup systemd service
source ${scripts}/java_utils.sh
retrieve_java_home "${HOST}"

sudo cp ${scripts}/systemd/flink-jm.service /etc/systemd/system/flink.service

sudo sed -i -e "s/{{USER}}/${USER}/g" -e "s@{{FLINK_HOME}}@${FLINK_HOME}@g" -e "s@{{JAVA_HOME}}@${JAVA_HOME}@g" -e "s@{{JOBMANAGER_HEAP}}@${JOBMANAGER_HEAP}@g" /etc/systemd/system/flink.service
sudo systemctl daemon-reload
#sudo systemctl enable flink.service

setServiceConfigured
log end