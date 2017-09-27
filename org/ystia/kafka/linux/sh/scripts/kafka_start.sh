#!/bin/bash
#
# Starlings
# Copyright (C) 2015 Bull S.A.S. - All rights reserved
#

source ${utils_scripts}/utils.sh
log begin

ensure_home_var_is_set

# Env file contains:
# KAFKA_HOME: Kafka installation path
# INSTANCE_ID: id of this zookeeper instance
# DATA_DIR: directory were data should be stored (default location if empty)
# KAFKA_SRV_NAME: Name of the Kafka service as registered in consul
# KAFKA_BASE_DNS_SRV_NAME: Base DNS service name for Kafka service
# KAFKA_ZK_SRV_NAME: Name of the Kafka-Zookeeper service as registered in consul
# KAFKA_ZK_BASE_DNS_SRV_NAME: Base DNS service name for Kafka-Zookeeper service
source ${HOME}/.starlings/${NODE}-service.env

# Ensure that scripts are executable
chmod +x ${scripts}/*.sh

# Check JAVA_HOME, KAFKA_HOME, ... are set
[ -z ${JAVA_HOME} ] && error_exit "JAVA_HOME not set"
[ -z ${KAFKA_HOME} ] && error_exit "KAFKA_HOME not set"

# Now wait for all zookeeper nodes to be pingable using there DNS name in cluster mode
for zk_node in $(cat ${KAFKA_HOME}/config/zookeeper.properties | egrep "^server\..+=.+:.+:.+$" | sed -e 's/^.*=\([^:]\+\):.*/\1/g'); do
    wait_for_address_to_be_pingable ${zk_node} 2048 || error_exit "Unable to reach ${zk_node} within the delay. Startup canceled."
done

# One of the processes, zookeeper or kafka, may running in case of relaunching process after unexpected process death
if is_port_open "127.0.0.1" "2181"
then
    log info "Zookeeper already started"
else
    log info "Starting Zookeeper"
    sudo systemctl start zookeeper
    wait_for_port_to_be_open "127.0.0.1" "2181" || error_exit "Cannot start zookeeper: port 2181 not open"
fi

log info "Waiting for ZooKeeper to be started..."
wait_for_command_to_succeed "/usr/bin/env utils_scripts=${utils_scripts} /bin/bash ${scripts}/kafka_checks.sh ${NODE} zookeeper ready" "180" || error_exit "Zookeeper failed to startup! Kafka startup canceled."

# One of the processes, zookeeper or kafka, may running in case of relaunching process after unexpected process death
if is_port_open "127.0.0.1" "9092"
then
    log info "Kafka server already started"
else
    log info "Starting Kafka server"
    # In some cases when restarting a ZooKeeper with existing data the ephemeral broker id node may not be unregistered when starting Kafka.
    # In this case Kafka starts but doesn't serves requests properly.
    # So let first check if the node is unregistred
    wait_for_command_to_succeed "/bin/bash -c 'export utils_scripts=${utils_scripts}; ${scripts}/kafka_checks.sh ${NODE} kafka ready; if [[ \$? -eq 0 ]] ; then exit 1; else exit 0; fi'" || error_exit "Kafka startup failed! This is likely due to another Kafka with the same id running somewhere else"

    log debug "Kafka server starting..."
    sudo systemctl start kafka
    log debug "Checking Kafka ready..."
    wait_for_command_to_succeed "/usr/bin/env utils_scripts=${utils_scripts} /bin/bash ${scripts}/kafka_checks.sh ${NODE} kafka ready" || error_exit "Kafka startup failed!"
fi

log end

