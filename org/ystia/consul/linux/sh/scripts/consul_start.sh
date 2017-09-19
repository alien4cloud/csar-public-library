#!/usr/bin/env bash

INSTALL_DIR=$(eval readlink -f "${INSTALL_DIR}")

. ${utils_scripts}/utils.sh
log begin

sudo systemctl start consul.service

timeout=$((600))
time=$((0))
while [[ ! -e  ${INSTALL_DIR}/work/consul.pid ]]; do
  sleep 1
  time=$((time + 1))
  [[ ${time} -gt ${timeout} ]] && { echo "Failed to start consul!!!"; exit 1; }
done

log end "Consul started."

