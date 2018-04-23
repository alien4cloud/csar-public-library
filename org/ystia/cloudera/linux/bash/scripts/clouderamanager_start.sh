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

sudo systemctl start cloudera-scm-server-db
wait_for_port_to_be_open "127.0.0.1" "7432" 120  || error_exit "Cannot open port 7432 (Embedded PostgreSQL Database)"

sudo systemctl start cloudera-scm-server
wait_for_port_to_be_open "127.0.0.1" "7180" 240  || error_exit "Cannot open port 7180 (Cloudera Manager Server)"

log end

