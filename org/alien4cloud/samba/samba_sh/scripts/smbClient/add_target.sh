#!/bin/bash -e
source $commons/commons.sh
echo "add_target" >> /home/ec2-user/toto.log
require_envs "MOUNT_POINT SAMBA_SERVER_IP SHARE_NAME"

## create the mounted point
sudo mkdir -p $MOUNT_POINT
sudo chmod 777 $MOUNT_POINT

if [[ "$(which yum)" != "" ]]
  then
    sudo mount -t cifs //$SAMBA_SERVER_IP/$SHARE_NAME $MOUNT_POINT -o rw,sec=ntlm,guest
elif [[ "$(which apt-get)" != "" ]]
  then
    sudo mount -t cifs -o //$SAMBA_SERVER_IP/$SHARE_NAME $MOUNT_POINT rw,sec=ntlm,guest
fi
