#!/usr/bin/env bash

source ${utils_scripts}/utils.sh
log begin

log info "A Replica Set Server IP Address and Port ${REPLICA_SET}/${TARGET_IP}:${DB_PORT} to be added to shard file"

lock "shard"
  # Add Replica Set Server node IP Address and Port for shard to shard file behind lock
  log info "sh.addShard(\"${REPLICA_SET}/${TARGET_IP}:${DB_PORT}\") to be added to shard file"
  
  if [[ ! -f ~/replica ]]; then
    echo "sh.status()" >>~/shard
    echo "sh.addShard(\"${REPLICA_SET}/${TARGET_IP}:${DB_PORT}\")" >>~/shard
    echo "sh.status()" >>~/shard
  else
    echo "sh.addShard(\"${REPLICA_SET}/${TARGET_IP}:${DB_PORT}\")" >>~/shard
    echo "sh.status()" >>~/shard
  fi
unlock "shard"

log info "Added <<<sh.addShard(\"${REPLICA_SET}/${TARGET_IP}:${DB_PORT}\")>>> to shard file"
    
log end
