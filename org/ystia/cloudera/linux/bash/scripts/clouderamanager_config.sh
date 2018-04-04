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
     log end "Cloudera Server component '${NODE}' already configured"
     exit 0
fi

sudo bash << EOF
[[ -f /etc/default/cloudera-scm-server ]] || error_exit "cloudera-scm-server defaults do not exist."
echo "USER='cloudera-scm'" >> /etc/default/cloudera-scm-server
echo "GROUP='cloudera-scm'" >> /etc/default/cloudera-scm-server
EOF

# TODO: Do not start ClouderaManager after reboot due to well known remaining problem about VM reboot
#sudo systemctl enable cloudera-scm-server-db
#sudo systemctl enable cloudera-scm-server

setServiceConfigured

log end
