#!/bin/bash -e
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source ${utils_scripts}/utils.sh

log begin

fs_mount_path=${FS_MOUNT_PATH}

log info "Unmounting file system on ${fs_mount_path}"
sudo umount -l ${fs_mount_path}

log info "Removing ${fs_mount_path} directory"
sudo rmdir ${fs_mount_path}

log end
