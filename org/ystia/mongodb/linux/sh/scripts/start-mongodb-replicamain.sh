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

# Wait for mongod to be ready to accept configuration commands
function WaitReady {
  IP=$1
  PORT=$2
  log info "Checking status of port ${PORT}...."
  while [[ -z $(echo "rs.status()" | mongo ${IP}:${PORT} | sed -n "/\"stateStr\" : \"PRIMARY\"/p") ]]; do
    log info "Waiting for mongod ${IP}:${PORT} to be ready to take initialize commands...."
    sleep 2
  done
  log info "mongod ${IP}:${PORT} is now ready."
}

log info "BEGIN mongo replica set start"

log info "systemctl start mongod"

#sudo systemctl start mongod
sudo systemctl start mongod
sudo systemctl status mongod

log info "Service mongo replica set start request issued"

# Wait for mongod to be listening on port ${DB_PORT}.
WaitPort ${DB_PORT}

# Begin the process of creating a replica set
#echo "rs.initiate()" | mongo ${DB_IP}:${DB_PORT}

# Wait for mongod to be ready to accept further configuration commands
#WaitReady ${DB_IP} ${DB_PORT}

# Execute mongo commands to configure Replica Set from file
log info "Issue the commands to initiate the Replica Set"
mongo ${DB_IP}:${DB_PORT} < ~/replica

log end
