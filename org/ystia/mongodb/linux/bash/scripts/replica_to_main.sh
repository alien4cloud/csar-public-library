#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source ${utils_scripts}/utils.sh
log begin

log info "A Replica Set Server IP Address and Port ${TARGET_IP}:${DB_PORT} to be added to replica file"

lock "replica"

  addresses=( $(get_multi_instances_attribute "TARGET_IP" "TARGET") )
  declare -p addresses
  # quote array values
  addresses=( ${addresses[@]/#/\"} )
  addresses=( ${addresses[@]/%/\"} )
  addr_block="$(join_list "," ${addresses[*]})"

  # Add Replica Set Server node IP Address and Port to replica file behind lock
  log info "${addr_block} to be added to replica file"

  for address in ${addresses[*]}
    do
      # remove quotation marks
      address=`echo "$address" | tr -d '"'`
      if [[ ! -f ~/replica ]]; then
        #echo "rs.conf()" >>~/replica
        #echo "rs.status()" >>~/replica
        #echo "rs.add(\"${address}:${DB_PORT}\")" >>~/replica
        #echo "rs.status()" >>~/replica
        echo "rs.initiate( { _id: \"${REPLICA_SET}\", members: [ { _id : 0, host : \"${SOURCE_IP}:${DB_PORT}\" }, { _id : 1, host : \"${address}:${DB_PORT}\" } ] } )" >>~/replica
        echo "${SOURCE_IP},${address}" >>~/list
      else
        #echo "rs.add(\"${address}:${DB_PORT}\")" >>~/replica
        #echo "rs.status()" >>~/replica
        count=`grep -o "_id" ~/replica | wc -l`
        count=$[$count-1]
        sed -i "/^rs.initiate/ s/ ] } )/, { _id : ${count}, host : \"${address}:${DB_PORT}\" } ] } )/" ~/replica
        sed -i "1 s/$/,${address}/" ~/list
      fi
    done

unlock "replica"

log info "Added <<<rs.add(\"${TARGET_IP}:${DB_PORT}\")>>> to replica file"
    
log end
