#!/bin/bash -e

source ${utils_scripts}/utils.sh

log begin

fs_mount_path=${FS_MOUNT_PATH}
filesys=${PARTITION_NAME}

if [ ! -f ${fs_mount_path} ]; then
    sudo mkdir -p ${fs_mount_path}
fi

log info "Mounting file system ${filesys} on ${fs_mount_path}"
sudo mount ${filesys} ${fs_mount_path}

user=$(whoami)
log info "Changing ownership of ${fs_mount_path} to ${user}"
sudo chown ${user} ${fs_mount_path}

log end