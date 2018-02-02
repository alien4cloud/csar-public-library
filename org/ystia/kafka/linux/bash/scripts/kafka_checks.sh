#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source ${utils_scripts}/utils.sh

ensure_home_var_is_set

usage () {
    log error "${BASH_SOURCE[0]} <alien_kafka_service_name> (kafka|zookeeper) (ready|pid)"
}

check_zookeeper_ready () {
    echo srvr | nc 127.0.0.1 2181 | egrep '(Mode: follower|Mode: leader|Mode: standalone)' > /dev/null 2>&1
    return $?
}

check_zookeeper_pid () {
    get_pid_from_port "2181"
}

check_kafka_pid () {
    get_pid_from_port "9092"
}

check_kafka_ready () {
    broker_id=${INSTANCE_ID}
    kafka_bin_path="${KAFKA_HOME}/bin"
    zookeeper_service_name=${KAFKA_ZK_BASE_DNS_SRV_NAME}
    result=$(echo "get /brokers/ids/${broker_id}" | ${kafka_bin_path}/zookeeper-shell.sh ${zookeeper_service_name}:2181 2>&1)
    if echo "$result" | grep -c "Node does not exist"; then
        return 1
    else
        return 0
    fi
}


if [[ "$#" != "3" ]]; then
    usage
    exit 255
fi

service_name=$1
source ${YSTIA_DIR}/${service_name}-service.env

component=$2
check=$3

eval "check_${component}_${check}"

