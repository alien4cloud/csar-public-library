#!/usr/bin/env bash


# Script env variables
# NODE: Current component name (used to resolve environment file)

source ${utils_scripts}/utils.sh
log begin
ensure_home_var_is_set

#pre-configure
cat >> "${YSTIA_DIR}/${SOURCE_NODE}-service.env" << EOF
PATH_FS=${path_fs}
EOF

#flag to inform that a blockstorage is connected
touch "${YSTIA_DIR}/.${SOURCE_NODE}-blockstorageFlag"

log end "Connect RStudio component '${SOURCE_NODE}' to a volume '${TARGET_NODE}' using path '${path_fs}'"

