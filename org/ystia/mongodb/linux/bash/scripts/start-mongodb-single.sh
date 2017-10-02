#!/usr/bin/env bash

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

log info "BEGIN mongo single server start"

log info "systemctl start mongod"

#sudo service mongod start
sudo systemctl start mongod
sudo systemctl status mongod

log info "Service mongo single server start request issued"

# Wait for mongod to be listening on port ${DB_PORT}.
WaitPort ${DB_PORT}

log end
 