#!/usr/bin/env bash

. ${utils_scripts}/utils.sh
log begin
log info "Gracefully leaving consul cluster"
sudo systemctl stop consul.service
log end
