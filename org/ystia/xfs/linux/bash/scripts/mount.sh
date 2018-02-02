#!/bin/bash -e
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#

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