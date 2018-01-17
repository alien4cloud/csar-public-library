#!/usr/bin/env bash

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
