#!/usr/bin/env bash

. ${utils_scripts}/utils.sh
log begin

log info "BEGIN mongo stop"

log info "systemctl stop mongod"

sudo systemctl stop mongod
sudo systemctl status mongod

log info "END service mongo stop"

log end
 