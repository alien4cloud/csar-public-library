#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source ${utils_scripts}/utils.sh
log begin

ensure_home_var_is_set


source ${YSTIA_DIR}/${HOST}-service.env

zk_nodes=$(cat ${KAFKA_HOME}/config/server.properties | grep -E "^zookeeper.connect=.+" | tail -1 | cut -d '=' -f 2)

more_args=""
# Add option min.insync.replicas
if [[ -n "${MIN_INSYNC_REPLICAS}" ]] && [[ "${MIN_INSYNC_REPLICAS}" != "null" ]]; then
    more_args="--config min.insync.replicas=${MIN_INSYNC_REPLICAS}"
fi

# Add options for retention
if [[ -n "$RETENTION_MINUTES" ]] && [[ "$RETENTION_MINUTES" != "null" ]]; then
    RETENTION_MS=$((RETENTION_MINUTES * 60000))
    more_args="$more_args --config retention.ms=$RETENTION_MS"
fi
if [[ -n "$SEGMENT_MINUTES" ]] && [[ "$SEGMENT_MINUTES" != "null" ]]; then
    SEGMENT_MS=$((SEGMENT_MINUTES * 60000))
    more_args="$more_args --config segment.ms=$SEGMENT_MS"
fi
if [[ -n "$SEGMENT_BYTES" ]] && [[ "$SEGMENT_BYTES" != "null" ]]; then
    more_args="$more_args --config segment.bytes=$SEGMENT_BYTES"
fi

log info "Creating topic ${TOPIC_NAME}"
if [[ "$(${KAFKA_HOME}/bin/kafka-topics.sh --zookeeper ${zk_nodes} --list --topic ${TOPIC_NAME} | wc -l)" == "0" ]]
then
   if ${KAFKA_HOME}/bin/kafka-topics.sh --zookeeper ${zk_nodes} --create --topic ${TOPIC_NAME} --replication-factor ${REPLICAS} --partitions ${PARTITIONS} ${more_args}
   then
       log end
   else
       # Do not exit on error, we may have sometimes the 'normal' error 'Topic X already exists' in case of Kafka cluster
       log end "Topic creation problem: may be topic already exist ?"
   fi
else
    log end "Kafka topic ${TOPIC_NAME} was already created by another instance"
fi


