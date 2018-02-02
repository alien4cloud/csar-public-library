#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


# Enviroment variables
# LOGSTASH_HOME: Logstash install home directory
# KAFKA_BASE_DNS_SRV_NAME: Kafka service base DNS name

source ${utils_scripts}/utils.sh
ensure_home_var_is_set

lock "$(basename $0)"

flag="${YSTIA_DIR}/.${SOURCE_NODE}-preconfiguresource-output-Flag"

if [[ -e "${flag}" ]]; then
    log info "Kafka input already configured, skipping."
    unlock "$(basename $0)"
    exit 0
fi

source ${YSTIA_DIR}/${SOURCE_NODE}-service.env

mkdir -p ${LOGSTASH_HOME}/conf

# Install dependencies
#   - jq for json parsing
log info "Installing jq for json parsing ..."
bash ${utils_scripts}/install-components.sh jq || error_exit "ERROR: Failed to install json parsing !!!"

#brooker_urls=()
#for brooker_id in $(curl -s http://127.0.0.1:8500/v1/catalog/service/kafka | jq -r '.[]|.ServiceTags[]'); do
#    brooker_urls+=("${brooker_id}.kafka.service.ystia:9092")
#done

#broker_urls are replaced by boostrap_servers
#can be a kafka brocker or a list of brovkers
#a kafka broker can be identified by "host:port"
#a list of brokers is defined by "host1:port1,host2:port2"
kafka_host_name="kafka.service.ystia"
kafka_port="9092"
kafka_host=$kafka_host_name:$kafka_port
log info "Kafka host is $kafka_host"

acks_config=""
if [[ -n "${REQUIRED_ACKS}" ]]; then
    acks_config="acks => "
    case "${REQUIRED_ACKS}" in
        "no_ack")
            acks_config="${acks_config} \"0\""
            ;;
        "leader")
            acks_config="${acks_config} \"1\""
            ;;
        "in_syncs")
            acks_config="${acks_config} \"all\""
            ;;
        *)
            error_exit "Unreconized value for REQUIRED_ACKS: '${REQUIRED_ACKS}'. Allowed values are 'no_ack', 'leader' or 'in_syncs'."
            ;;
    esac
fi
retries_config=""
if [[ -n "${MESSAGE_MAX_RETRIES}" ]] && [[ "${MESSAGE_MAX_RETRIES}" != "null" ]]; then
    retries_config="retries => ${MESSAGE_MAX_RETRIES}"
fi
retry_backoff_ms_config=""
if [[ -n "${RETRY_BACKOFF_MS}" ]] && [[ "${RETRY_BACKOFF_MS}" != "null" ]]; then
    retry_backoff_ms_config="retry_backoff_ms => ${RETRY_BACKOFF_MS}"
fi
request_timeout_ms_config=""
if [[ -n "${REQUEST_TIMEOUT_MS}" ]] && [[ "${REQUEST_TIMEOUT_MS}" != "null" ]]; then
    request_timeout_ms_config="request_timeout_ms => \"${REQUEST_TIMEOUT_MS}\""
fi

LS_JAVA_OPTS=${JAVA_OPTS}

cat > ${LOGSTASH_HOME}/conf/3-kafka_logstash_outputs.conf << END
output {
    kafka {
        topic_id => "${TOPIC_NAME}"
        bootstrap_servers => "${kafka_host}"
        ${acks_config}
        ${retries_config}
        ${retry_backoff_ms_config}
        ${request_timeout_ms_config}
    }
}
END

touch "${flag}"
unlock "$(basename $0)"
