#!/usr/bin/env bash

. ${utils_scripts}/utils.sh
log begin

log info "BEGIN mongos stop"

log info "systemctl stop mongos"

#sudo systemctl stop mongos
#sudo systemctl status mongos

log info "END service mongos stop"

log end