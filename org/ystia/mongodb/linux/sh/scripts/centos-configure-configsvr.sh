#!/usr/bin/env bash

. ${utils_scripts}/utils.sh
log begin

log info "BEGIN configure of mongo for Centos"

sudo service mongod stop

log info "change mongo bind ip to ${DB_IP}"
sudo sed -i "s/  bindIp.*/  bindIp: ${DB_IP}/" /etc/mongod.conf

log info "change mongo bind port to 27200"
sudo sed -i "s/  port.*/  port: 27200/" /etc/mongod.conf
log info "Provide port 27200 to SElinux"
sudo semanage port -a -t mongod_port_t -p tcp 27200

log info "Add configsvr configuration info to /etc/mongod.conf"
echo "replication:" | sudo tee --append /etc/mongod.conf
echo "  replSetName: config" | sudo tee --append /etc/mongod.conf
echo " " | sudo tee --append /etc/mongod.conf
echo "sharding:" | sudo tee --append /etc/mongod.conf
echo "  clusterRole: configsvr" | sudo tee --append /etc/mongod.conf

log info "Set Maximum number of processes for mongod"
echo "mongod     soft    nproc     64000" | sudo tee --append /etc/security/limits.d/20-nproc.conf

log info "Set MongoDB to start on reboot"
sudo chkconfig mongod on

log info "END configure of mongo"

log end 