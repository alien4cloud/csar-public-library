#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#

source ${utils_scripts}/utils.sh

log begin

source ${consul_utils}/utils.sh
ensure_home_var_is_set

log info "JAVA_HOME=$JAVA_HOME"
ES_HOME="$HOME/elasticsearch-${ES_VERSION}"
source ${scripts}/es_utils.sh

if isServiceConfigured; then
     log end "Elasticsearch component '${NODE}' already configured"
     exit 0
fi

# Check JAVA_HOME, ...
[ -z ${JAVA_HOME} ] && error_exit "JAVA_HOME not set"

# Increase the maximum file open limit to avoid a warning at elasticsearch startup
sudo bash -c 'echo "* - nofile 65536" >>/etc/security/limits.conf'

# Set environment variable used for systemd
# Note: Remove -Xmx512m option in JAVA_OPTS added by gigaspaces/tools/groovy/bin/startGroovy
JAVA_OPTS_2=$(echo ${JAVA_OPTS} |sed -s 's|-Xmx[0-9]*[a-zA-Z]||')
export JAVA_OPTS=${JAVA_OPTS_2}

# Setup systemd service
sudo cp ${scripts}/systemd/elasticsearch.service /etc/systemd/system/elasticsearch.service
sudo sed -i -e "s/%USER%/${USER}/g" -e "s@%ES_HOME%@${ES_HOME}@g" -e "s@%JAVA_HOME%@${JAVA_HOME}@g" -e "s/%JAVA_OPTS%/${JAVA_OPTS}/g" /etc/systemd/system/elasticsearch.service
sudo systemctl daemon-reload
#sudo systemctl enable elasticsearch.service

# Set JVM heap size via jvm.options
JVM_OPTIONS_FILE=${CONFIG_PATH}/jvm.options
sed -i -e "s/^-Xms.*$/-Xms${ELASTICSEARCH_HEAP_SIZE}/g" -e "s/^-Xmx.*$/-Xmx${ELASTICSEARCH_HEAP_SIZE}/g" ${JVM_OPTIONS_FILE}

cp ${CONFIG_PATH}/elasticsearch.yml ${CONFIG_PATH}/elasticsearch.yml.original_backup
cp ${config_file} "${CONFIG_PATH}/elasticsearch.yml"

# Take into account elk-all-in-one topo. Is consul agent present ?
if is_port_open "127.0.0.1" "8500"
then
    IS_CONSUL=0
    # Register the service in consul
    ES_BASE_DNS_SERVICE_NAME="elasticsearch.service.ystia"
    INSTANCE_ID="$(get_new_id service/elasticsearch retry |tail -1)"
    register_consul_service=${consul_utils}/register-consul-service.py
    chmod +x ${register_consul_service}
    log info "Register the service in consul: name=elasticsearch, port=9300, address=${ip_address}, tag=${INSTANCE_ID}"
    ${register_consul_service} -s elasticsearch -p 9300 -a ${ip_address} -t ${INSTANCE_ID}
else
    IS_CONSUL=1
    log warning "Service Consul is not here."
fi

# Configure the cluster
update_property "cluster.name" "${cluster_name}"
if [[ "$IS_CONSUL" -eq "0" ]]
then
    update_property "node.name" "${INSTANCE_ID}.${ES_BASE_DNS_SERVICE_NAME}"
    update_property "network.publish_host" "${INSTANCE_ID}.${ES_BASE_DNS_SERVICE_NAME}"
    update_property "discovery.zen.ping.unicast.hosts" "${ES_BASE_DNS_SERVICE_NAME}"
else
    update_property "node.name" "elasticsearch_${ip_address}"
    update_property "network.publish_host" "${ip_address}"
fi

setServiceConfigured
log info "Elasticsearch end configuring"

# Curator crontab configuration
os_distribution="$(get_os_distribution)"
if [[ "${os_distribution}" == "ubuntu" ]]
then
    CURATOR_CMD="/usr/local/bin/curator"
    CRON_SERVICE_NAME="cron"
else
    CURATOR_CMD="/usr/bin/curator"
    CRON_SERVICE_NAME="crond"
fi

userAddReturnCode=$(sudo useradd curator; echo $?)

if [[ $userAddReturnCode != 0 && $userAddReturnCode != 9 ]]
then
    log error "Unable to create user curator"
    exit 1
fi


if [[ -s ${curator_cron_tab} ]]
then
    log info "Use a user provided curator crontab file"
    cp ${curator_cron_tab} /tmp/curator-crontab
else
    cp ${curator_action_file} /tmp/curact1

    # Check parameters for close
    if [[ -n "$nb_close_older_than" && -n "$unit_close_older_than" ]]
    then
        log info "Set curator to close elasticsearch indices older than ${nb_close_older_than} ${unit_close_older_than}"
        cat /tmp/curact1 | sed "s;%CLOSE_NB%;${nb_close_older_than};" | sed "s;%CLOSE_UNIT%;${unit_close_older_than};" >/tmp/curact2
    else
        cat /tmp/curact1 | sed "s;disable_action: False;disable_action: True;" >/tmp/curact2
    fi
    # Check parameters for delete
    if [[ -n "$nb_delete_older_than" && -n "$unit_delete_older_than" ]]
    then
        log info "Set curator delete elasticsearch indices older than ${nb_delete_older_than} ${unit_delete_older_than}"
        cat /tmp/curact2 | sed "s;%DELETE_NB%;${nb_delete_older_than};" | sed "s;%DELETE_UNIT%;${unit_delete_older_than};" >/tmp/curator-action
    fi
    cat >> /tmp/curator-crontab <<EOF
0 2 * * *    LC_ALL=en_US.utf8 $CURATOR_CMD --config /home/curator/curator.yml /home/curator/curator-action
EOF
fi

if [ -f "/tmp/curator-crontab" ]
then
    if [ -f /tmp/curator-action ]
    then
        sudo mv /tmp/curator-action /home/curator
    fi
    sudo cp ${curator_config_file} /home/curator/curator.yml
    sudo crontab -u curator /tmp/curator-crontab
    sudo service ${CRON_SERVICE_NAME} restart
    log info "Curator is configured"
else
    log info "Curator is not used"
fi

log end