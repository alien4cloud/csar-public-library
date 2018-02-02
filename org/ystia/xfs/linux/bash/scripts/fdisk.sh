#!/bin/bash -e
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source ${utils_scripts}/utils.sh

log begin

partition_number=1
partition_type=${PARTITION_TYPE}
device_name=${DEVICE}

log info "Checking existing partition for $device_name"

if sudo fdisk -l $device_name 2>/dev/null | grep -E "$device_name[0-9]"; then
    log info "Not partitioning device since a partition already exist"
else
    log info "Creating disk partition on device ${device_name}"
    (echo n; echo p; echo ${partition_number}; echo ; echo ; echo t; echo ${partition_type}; echo w) | sudo fdisk ${device_name}
fi

# Set this runtime property on the source (the filesystem)
# its needed by subsequent scripts
# ctx source instance runtime-properties filesys ${device_name}${partition_number}
export PARTITION_NAME=${device_name}${partition_number}

log end
