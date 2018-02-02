#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


. ${utils_scripts}/utils.sh
log begin

# Wait for port to be listening.
function WaitPort {
  PORT=$1
  sleep 2
  log info "Checking status of port ${PORT}...."
  while [[ -z "$(sudo netstat -tlnp | grep ${PORT})" ]]; do
    log info "Waiting for program to initialize on port ${PORT}...."
    sleep 2
  done
  log info "Program is now running on port ${PORT}."
  sudo netstat -tlnp | grep ${PORT}
}

log info "BEGIN mongo replica set start"

log info "systemctl start mongod"

#sudo service mongod start
sudo systemctl start mongod
sudo systemctl status mongod

log info "Service mongo replica set start request issued"

# Wait for mongod to be listening on port ${DB_PORT}.
WaitPort ${DB_PORT}

log end
