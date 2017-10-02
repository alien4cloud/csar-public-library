#!/usr/bin/env bash
#
# Starlings
# Copyright (C) 2015 Bull S.A.S. - All rights reserved
#

# Script env variables
# NODE: Current component name (used to resolve environement file)


source ${utils_scripts}/utils.sh
log begin
ensure_home_var_is_set

#pre-configure
cat >> "${STARLINGS_DIR}/${SOURCE_NODE}-service.env" << EOF
DATA_DIR=${path_fs}
EOF

#flag to inform that a volume is connected
touch "${STARLINGS_DIR}/.${SOURCE_NODE}-volumeFlag"

log end "Connect Kafka component '${SOURCE_NODE}' to a volume '${TARGET_NODE}' using path '${volume_location}'"