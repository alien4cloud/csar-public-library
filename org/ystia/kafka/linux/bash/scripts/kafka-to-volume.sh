#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#

# Script env variables
# NODE: Current component name (used to resolve environement file)


source ${utils_scripts}/utils.sh
log begin
ensure_home_var_is_set

#pre-configure
cat >> "${YSTIA_DIR}/${SOURCE_NODE}-service.env" << EOF
DATA_DIR=${path_fs}
EOF

#flag to inform that a volume is connected
touch "${YSTIA_DIR}/.${SOURCE_NODE}-volumeFlag"

log end "Connect Kafka component '${SOURCE_NODE}' to a volume '${TARGET_NODE}' using path '${volume_location}'"