#!/usr/bin/env bash
#
# Starlings
# Copyright (C) 2016 Bull S.A.S. - All rights reserved
#

source ${utils_scripts}/utils.sh

log begin

# To set variables for the proxy
ensure_home_var_is_set

if isServiceConfigured; then
     log end "Cloudera Agent component '${NODE}' already configured"
     exit 0
fi

[[ -f /etc/cloudera-scm-agent/config.ini ]] || error_exit "Cloudera Agent config does not exist."

log "Cloudera Manager Server ip is ${TARGET_IP}"
sudo bash <<EOF
sed -i "s/server_host=localhost/server_host=${TARGET_IP}/" /etc/cloudera-scm-agent/config.ini
EOF

# TODO: Do not start ClouderaAgent after reboot due to well known remaining problem about VM reboot
#sudo systemctl enable cloudera-scm-agent

setServiceConfigured

log end


