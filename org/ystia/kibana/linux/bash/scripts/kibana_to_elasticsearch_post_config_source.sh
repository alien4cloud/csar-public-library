#!/usr/bin/env bash

source ${utils_scripts}/utils.sh

log begin

ensure_home_var_is_set

# To set ELASTICSEARCH_HOME
source ${YSTIA_DIR}/kibana_env.sh

# TODO: comment
env |sort

log debug "$0: Target: ${TARGET_NODE}/${TARGET_INSTANCE} and Source ${SOURCE_NODE}/${SOURCE_INSTANCE}"
log debug "$0: kibanaIp=${kibanaIp} and elasticsearchIp=${elasticsearchIp}"

# If Kibana and Elasticsearch are on same host, Elasticsearch client node is not necessary
[[ "${kibanaIp}" = "${elasticsearchIp}" ]] && log info "$0: Not needed to install an elasticsearch client node for kibana" && exit 0

# TODO: comment
env |sort

# Configure Elasticsearch as a client node
ES_SERVICE_NAME="elasticsearch"
echo "cluster.name: ${cluster_name}" > ${ELASTICSEARCH_HOME}/config/elasticsearch.yml
echo "node.name: client4kibana.${ES_SERVICE_NAME}.service.starlings" >> ${ELASTICSEARCH_HOME}/config/elasticsearch.yml
echo "node.master: false" >> ${ELASTICSEARCH_HOME}/config/elasticsearch.yml
echo "node.data: false" >> ${ELASTICSEARCH_HOME}/config/elasticsearch.yml
echo "network.bind_host: 0.0.0.0" >> ${ELASTICSEARCH_HOME}/config/elasticsearch.yml
echo "network.publish_host: ${kibanaIp}" >> ${ELASTICSEARCH_HOME}/config/elasticsearch.yml
echo "discovery.zen.ping.unicast.hosts: [\"${ES_SERVICE_NAME}.service.starlings\"]" >> ${ELASTICSEARCH_HOME}/config/elasticsearch.yml

# Set JVM heap size via jvm.options
JVM_OPTIONS_FILE=${ELASTICSEARCH_HOME}/config/jvm.options
sed -i -e "s/^-Xms.*$/-Xms${ELASTICSEARCH_HEAP_SIZE}/g" -e "s/^-Xmx.*$/-Xmx${ELASTICSEARCH_HEAP_SIZE}/g" ${JVM_OPTIONS_FILE}

# Set environment variable used for systemd
#source ${scripts}/java_utils.sh
#retrieve_java_home "${HOST}"
# Note: Remove -Xmx512m option in JAVA_OPTS added by gigaspaces/tools/groovy/bin/startGroovy
JAVA_OPTS_2=$(echo ${JAVA_OPTS} |sed -s 's|-Xmx[0-9]*[a-zA-Z]||')
export JAVA_OPTS=${JAVA_OPTS_2}


# Avoid ERROR: {max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]}
sudo sysctl -w vm.max_map_count=262144

# Setup elasticsearch systemd service
sudo cp ${scripts}/systemd/elasticsearch.service /etc/systemd/system/elasticsearch.service
sudo sed -i -e "s/{{USER}}/${USER}/g" -e "s@{{ELASTICSEARCH_HOME}}@${ELASTICSEARCH_HOME}@g" -e "s@{{JAVA_HOME}}@${JAVA_HOME}@g" -e "s/{{JAVA_OPTS}}/${JAVA_OPTS}/g" /etc/systemd/system/elasticsearch.service
sudo systemctl daemon-reload
#sudo systemctl enable elasticsearch.service

# Define in kibana.service the dependency to elasticsearch.service
sudo sed -i -e "s/#{{UNCOMMENT}}//g"  /etc/systemd/system/kibana.service
sudo systemctl daemon-reload

log end