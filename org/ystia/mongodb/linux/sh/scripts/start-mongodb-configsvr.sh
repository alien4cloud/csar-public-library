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

log info "BEGIN mongo configsvr start"
log info "service mongo start"

#sudo systemctl start mongod
sudo systemctl start mongod
sudo systemctl status mongod

log info "Service mongo configsvr start request issued"

# Wait for mongod to be listening on port 27200.
WaitPort 27200

log end

