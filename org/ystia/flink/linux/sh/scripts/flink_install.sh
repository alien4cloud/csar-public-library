#!/usr/bin/env bash
#
# Starlings
# Copyright (C) 2015 Bull S.A.S. - All rights reserved
#

source ${utils_scripts}/utils.sh
log begin

source ${scripts}/flink-service.properties

log info "Flink Download URL = $FLINK_DOWNLOAD_PATH"

ensure_home_var_is_set

if isServiceInstalled; then
    log info "Flink component '${NODE}' already installed"
    exit 0
fi

# Install dependencies
#   - jq for json parsing needed by consul_utils/utils.sh
bash ${utils_scripts}/install-components.sh jq wget

INSTALL_DIR="${HOME}/${FLINK_SERVICE_NAME}"
TARGET_DIR="${INSTALL_DIR}/${FLINK_UNZIP_FOLDER}"

cat > "${STARLINGS_DIR}/${NODE}-service.env" << EOF
FLINK_HOME=${TARGET_DIR}
EOF

if [[ -n "${REPOSITORY}" ]] && [[ "${REPOSITORY}" != "DEFAULT" ]] && [[ "${REPOSITORY}" != "null" ]]; then
    FLINK_DOWNLOAD_PATH="${REPOSITORY}/${FLINK_ZIP_NAME}"
fi

mkdir -p ${INSTALL_DIR}
log info "Downloading Flink..."
wget "${FLINK_DOWNLOAD_PATH}" -P "${INSTALL_DIR}" -N
log info "Flink downloaded successfully."
tar xzf ${INSTALL_DIR}/${FLINK_ZIP_NAME} -C ${INSTALL_DIR}
chmod +x ${TARGET_DIR}/bin/*
rm -f ${INSTALL_DIR}/${FLINK_ZIP_NAME}

setServiceInstalled

log end "Flink installed in ${INSTALL_DIR}"
