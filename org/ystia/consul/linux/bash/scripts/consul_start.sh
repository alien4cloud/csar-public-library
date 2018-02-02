#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


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

