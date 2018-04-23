#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
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


