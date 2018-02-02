#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#

. ${utils_scripts}/utils.sh
log begin

log info "BEGIN configure of mongo for Centos"

sudo service mongod stop

log info "change mongo bind ip to ${DB_IP}"
sudo sed -i "s/  bindIp.*/  bindIp: ${DB_IP}/" /etc/mongod.conf

log info "change mongo bind port to ${DB_PORT}"
sudo sed -i "s/  port.*/  port: ${DB_PORT}/" /etc/mongod.conf
log info "Provide port ${DB_PORT} to SElinux"
sudo semanage port -a -t mongod_port_t -p tcp ${DB_PORT}

log info "Add replica set configuration info to /etc/mongod.conf"

log info "SHARD is set to ${SHARD}"
if [[ "$SHARD" == "true" ]]; then
  echo "sharding:" | sudo tee --append /etc/mongod.conf
  echo "  clusterRole: shardsvr" | sudo tee --append /etc/mongod.conf
  echo " " | sudo tee --append /etc/mongod.conf
fi

echo "replication:" | sudo tee --append /etc/mongod.conf
echo "  replSetName: ${REPLICA_SET}" | sudo tee --append /etc/mongod.conf
echo " " | sudo tee --append /etc/mongod.conf

log info "Set Maximum number of processes for mongod"
echo "mongod     soft    nproc     64000" | sudo tee --append /etc/security/limits.d/20-nproc.conf

log info "Set MongoDB to start on reboot"
sudo chkconfig mongod on

log info "END configure of mongo"

log end 