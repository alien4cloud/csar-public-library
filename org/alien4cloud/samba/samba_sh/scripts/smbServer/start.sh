#!/bin/bash -e
source $commons/commons.sh

require_bin "smbd nmbd"

if [[ "$(which yum)" != "" ]]
  then
  sudo systemctl restart smb
  sudo systemctl restart nmb
elif [[ "$(which apt-get)" != "" ]]
  then
    sudo service smbd restart
    sudo service nmbd restart
fi
