#!/bin/bash
#
# Starlings
# Copyright (C) 2016 Bull S.A.S. - All rights reserved
#

source ${utils_scripts}/utils.sh
log begin

# To set variables for the proxy
ensure_home_var_is_set

sudo systemctl start cloudera-scm-server-db
wait_for_port_to_be_open "127.0.0.1" "7432" 120  || error_exit "Cannot open port 7432 (Embedded PostgreSQL Database)"

sudo systemctl start cloudera-scm-server
wait_for_port_to_be_open "127.0.0.1" "7180" 240  || error_exit "Cannot open port 7180 (Cloudera Manager Server)"

log end

