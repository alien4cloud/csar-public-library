#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source ${utils_scripts}/utils.sh
# To set variables for the proxy
ensure_home_var_is_set

log begin

source /etc/bashrc

log info "Starting Jupyter..."

sudo systemctl start jupyter

sleep 2
wait_for_port_to_be_open "127.0.0.1" 9888 || error_exit "Cannot start Jupyter"

log end "Jupyter started !"
