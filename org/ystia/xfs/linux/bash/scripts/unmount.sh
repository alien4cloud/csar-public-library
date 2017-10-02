#!/bin/bash -e

source ${utils_scripts}/utils.sh

log begin

fs_mount_path=${FS_MOUNT_PATH}

log info "Unmounting file system on ${fs_mount_path}"
sudo umount -l ${fs_mount_path}

log info "Removing ${fs_mount_path} directory"
sudo rmdir ${fs_mount_path}

log end
