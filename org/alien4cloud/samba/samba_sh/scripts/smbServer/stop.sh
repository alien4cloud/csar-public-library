#!/bin/bash -e
source $commons/commons.sh

require_bin "smbd nmbd"

if [[ "$(which yum)" != "" ]]
  then
  sudo systemctl stop smb
  sudo systemctl stop nmb
elif [[ "$(which apt-get)" != "" ]]
  then
    sudo service smbd stop
    sudo service nmbd stop
fi
