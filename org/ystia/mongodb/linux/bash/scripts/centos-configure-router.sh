#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#

. ${utils_scripts}/utils.sh
log begin

log info "BEGIN configure of mongos for Centos"

log info "sudo cp ${data}/mongos.conf /etc/mongos.conf"
sudo cp ${data}/mongos.conf /etc/mongos.conf

log info "change mongo bind ip to ${DB_IP}"
sudo sed -i "s/  bindIp.*/  bindIp: ${DB_IP}/" /etc/mongos.conf

if [[ ! -z "$DB_PORT" ]]; then
  log info "change mongo bind port to ${DB_PORT}"
  sudo sed -i "s/  port.*/  port: ${DB_PORT}/" /etc/mongos.conf
  log info "Provide port ${DB_PORT} to SElinux"
  sudo semanage port -a -t mongod_port_t -p tcp ${DB_PORT}
else
  log info "Provide port 27017 to SElinux"
  sudo semanage port -a -t mongod_port_t -p tcp 27017
fi

log info "Add Router configuration info to /etc/mongos.conf"
echo "sharding:" | sudo tee --append /etc/mongos.conf
echo "  configDB: " | sudo tee --append /etc/mongos.conf

log info "Set Maximum number of processes for mongos"
echo "mongos     soft    nproc     64000" | sudo tee --append /etc/security/limits.d/20-nproc.conf

#log info "Set mongos to start on reboot"
#sudo chkconfig mongos on

log info "END configure of mongos"

log end 