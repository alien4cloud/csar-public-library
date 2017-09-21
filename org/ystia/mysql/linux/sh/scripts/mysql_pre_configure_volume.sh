#!/bin/bash

source $utils_scripts/utils.sh
log begin
log info "Target: ${TARGET_BLOCKSTORAGE_DEVICE}"
source $scripts/$(get_os_distribution)/setPath.sh ${TARGET_BLOCKSTORAGE_DEVICE}
log end
