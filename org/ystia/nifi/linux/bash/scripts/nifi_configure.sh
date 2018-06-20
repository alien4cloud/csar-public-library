#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#

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

# Follow Nifi configuration Best practices: https://nifi.apache.org/docs/nifi-docs/html/administration-guide.html#configuration-best-practices

#
# Updates a configuration option (comment it out if already defined)
# params:
#   1- attribute name
#   2- attribute value
#   3- file to update
#   4- separator
update_config_option () {
    # first comment out explicit auto topic creation parameter if any
    sed -i -e "s/^\s*${1}=/#&/g" ${3}
    # then explicitly set it to selected value
    echo "${1} ${4} ${2}" >> ${3}
}

# Maximum File Handles
update_config_option "* hard nofile" "50000" "/etc/security/limits.conf" " "
update_config_option "* soft nofile" "50000" "/etc/security/limits.conf" " "

# Maximum Forked Processes
update_config_option "* hard nproc" "10000" "/etc/security/limits.conf" " "
update_config_option "* soft nproc" "10000" "/etc/security/limits.conf" " "
update_config_option "* soft nproc" "10000" "/etc/security/limits.d/20-nproc.conf" " "

# Increase the number of TCP socket ports available
sudo sysctl -w net.ipv4.ip_local_port_range="10000 65000"

# Set how long sockets stay in a TIMED_WAIT state when closed
#sudo sysctl -w net.ipv4.netfilter.ip_conntrack_tcp_timeout_time_wait="1"

# Tell Linux you never want NiFi to swap
update_config_option "vm.swappiness" "0" "/etc/sysctl.conf" "="

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
