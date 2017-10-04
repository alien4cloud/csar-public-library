#!/bin/bash

start_nginx () {
  if [[ "$(which yum)" != "" ]]
    then
    sudo systemctl restart nginx
  elif [[ "$(which apt-get)" != "" ]]
    then
    sudo /etc/init.d/nginx reload
  fi
}

start_nginx
