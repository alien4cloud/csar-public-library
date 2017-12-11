#!/usr/bin/env bash

source ${utils_scripts}/utils.sh
log begin

ensure_home_var_is_set

if isServiceConfigured; then
     log end "nifi component '${NODE}' already configured"
     exit 0
fi

# Check JAVA_HOME, NIFI_HOME, ...
[ -z ${JAVA_HOME} ] && error_exit "JAVA_HOME not set"
[ -z ${NIFI_HOME} ] && error_exit "NIFI_HOME not set"


# Setup systemd service
sudo cp ${scripts}/systemd/nifi.service /etc/systemd/system/nifi.service
sudo sed -i -e "s/{{USER}}/${USER}/g" -e "s@{{NIFI_HOME}}@${NIFI_HOME}@g" -e "s@{{JAVA_HOME}}@${JAVA_HOME}@g" /etc/systemd/system/nifi.service
sudo systemctl daemon-reload
#sudo systemctl enable nifi.service


# Is consul agent present ?
if is_port_open "127.0.0.1" "8500"
then
    # Register the service in consul
    NIFI_BASE_DNS_SERVICE_NAME="nifi.service.ystia"
    INSTANCE_ID="$(get_new_id service/nifi retry |tail -1)"
    register_consul_service=${consul_utils}/register-consul-service.py
    chmod +x ${register_consul_service}
    log info "Register the service in consul: name=nifi, port=8080, address=${IP_ADDRESS}, tag=${INSTANCE_ID}"
    ${register_consul_service} -s nifi -p 8080 -a ${IP_ADDRESS} -t ${INSTANCE_ID}
else
    log warning "Service Consul is not here."
fi


setServiceConfigured
log end