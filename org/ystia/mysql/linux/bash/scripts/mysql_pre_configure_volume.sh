#!/bin/bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source $utils_scripts/utils.sh
log begin
log info "Target: ${TARGET_BLOCKSTORAGE_DEVICE}"
source $scripts/$(get_os_distribution)/setPath.sh ${TARGET_BLOCKSTORAGE_DEVICE}
log end
