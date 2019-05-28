#!/bin/bash -e
source $commons/commons.sh

require_envs "DATA_DIR SERVER_PROTOCOL"

if [ "$SERVER_PROTOCOL" == "https" ]; then

  AC4_SSL_DIR=/etc/alien4cloud/ssl
  echo "Cleaning up $AC4_SSL_DIR directory"

  sudo /bin/rm -Rf $AC4_SSL_DIR

fi

echo "Cleaning up $DATA_DIR directory"
sudo /bin/rm -Rf $DATA_DIR

echo "Cleaning up Alien4Cloud installation directory"
sudo /bin/rm -Rf /opt/alien4cloud

