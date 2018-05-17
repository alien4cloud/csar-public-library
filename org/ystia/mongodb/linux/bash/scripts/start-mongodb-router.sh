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

# Restart all replicas that are part of the shard replica sets
function RestartReplicas {
  OIFS=$IFS
  IFS=','
  
  cp ${YSTIA_DIR}/mongodb_shard ${YSTIA_DIR}/mongodb_shardx
  
  c_shard=`sed -n "/^sh.addShard/{p;q;}" ${YSTIA_DIR}/mongodb_shardx`
  while [[ ! -z "$c_shard" ]]; do
    echo "<<<$c_shard>>>"
    rs_name=`expr match "$c_shard" '.*\"\(.*\)/'`
    rs_ip=`expr match "$c_shard" '.*/\(.*\):'`
    echo "Replica Set name is <<<$rs_name>>> and IP is <<<$rs_ip>>>"
    
    list=`ssh -o StrictHostKeyChecking=no -o LogLevel=Error $rs_ip cat list`
    echo "list is <<<$list>>>"
    for x in $list; do
      echo "IP is [$x]"
      ssh -o StrictHostKeyChecking=no -o LogLevel=Error $x sudo systemctl restart mongod
      ssh -o StrictHostKeyChecking=no -o LogLevel=Error $x sudo systemctl status mongod
    done
    
    sed -i "0,/sh.addShard/{//d;}" ${YSTIA_DIR}/mongodb_shardx
    c_shard=`sed -n "/^sh.addShard/{p;q;}" ${YSTIA_DIR}/mongodb_shardx`
  done
  
  IFS=$OIFS

}

log info "BEGIN mongo router start"

#sudo echo "line used to check if mongo is restarting, do not delete it" | sudo tee -a /var/log/mongodb/mongod.log

# Complete configuration of Config Server by issuing the rs.initiate() command
rs_cmnd=`sed -n "/^rs.initiate/p" ~/config.init`
log info "${rs_cmnd}"
configsvr_ip_port=`expr match "$rs_cmnd" '.*host : "\(.*\)"'`
log info "Issue the rs.initiate command to ${configsvr_ip_port} to initiate the Config Server replica set"
mongo $configsvr_ip_port < ~/config.init

# Complete configuration of Router by adding configDB option to configuration file.
configDB=`sed -n "/^configDB/p" ~/configdb`
log info "${configDB}"
sudo sed -i "s[^  configDB: [  ${configDB}[" /etc/mongos.conf

log info "sleep 60"
sleep 60

log info "Program mongos start"

sudo mongos --config /etc/mongos.conf

log info "Program mongos Router start request issued"

# Wait for mongos to be listening on port ${DB_PORT}.
WaitPort $DB_PORT

log info "Issue the commands from file \"shard\" to connect to the database shards"
mongo ${DB_IP}:${DB_PORT} < ${YSTIA_DIR}/mongodb_shard

log info "sleep 60"
sleep 60

# Restart all replicas that are part of the shard replica sets
log info "Restart all replicas that are part of the shard replica sets"
RestartReplicas

log end
