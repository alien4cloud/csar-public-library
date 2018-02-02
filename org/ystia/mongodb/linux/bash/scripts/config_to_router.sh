#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source ${utils_scripts}/utils.sh
log begin

log info "Config Server IP Address and Port ${TARGET_IP}:27200 to be added to configdb file"

lock "configdb"
  # Add Config Server node IP Address to configdb file behind lock
  log info "${TARGET_IP}:27200 to be added to configdb file"
  
  if [[ ! -f ~/configdb ]]; then
    echo "configDB: config/${TARGET_IP}:27200" >>~/configdb
    echo "rs.initiate( { _id: \"config\", configsvr: true, members: [ { _id : 0, host : \"${TARGET_IP}:27200\" } ] } )" >>~/config.init
  else
    sed -i "/^configDB/ s/$/,${TARGET_IP}:27200/" ~/configdb
    count=`grep -o "_id" ~/config.init | wc -l`
    count=$[$count-1]
    sed -i "/^rs.initiate/ s/ ] } )/, { _id : ${count}, host : \"${TARGET_IP}:27200\" } ] } )/" ~/config.init
  fi
unlock "configdb"

log info "Added <<<${TARGET_IP}:27200>>> to configdb file"
    
log end
