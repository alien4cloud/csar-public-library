#!/bin/bash -e

source ${utils_scripts}/utils.sh

log begin

fs_type="xfs"
filesys=${PARTITION_NAME}

EXISTING_FS_TYPE=$(sudo lsblk -no FSTYPE $PARTITION_NAME)
if [ -z $EXISTING_FS_TYPE ] ; then
    mkfs_executable='mkfs.xfs'

    log info "Creating xfs file system using ${mkfs_executable}"
    sudo ${mkfs_executable} ${filesys}
else
    if [ "$EXISTING_FS_TYPE" != "$fs_type" ] ; then
        log info "Existing filesystem ($EXISTING_FS_TYPE) but not the expected type ($fs_type)"
        exit 1
    fi
    echo "Not making a filesystem since as it already exists."
fi

log end
