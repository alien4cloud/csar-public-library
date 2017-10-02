#!/usr/bin/env bash

source ${utils_scripts}/utils.sh
log begin

FLINK_ZIP_FILE=flink-${FLINK_VERSION}-bin-hadoop27-scala_2.11.tgz
FLINK_DOWNLOAD_PATH="${FLINK_REPO}/flink-${FLINK_VERSION}/${FLINK_ZIP_FILE}"

log info "Flink Download URL = $FLINK_DOWNLOAD_PATH"

ensure_home_var_is_set

if isServiceInstalled; then
    log info "Flink component '${NODE}' already installed"
    exit 0
fi

# Install dependencies
#   - jq for json parsing needed by consul_utils/utils.sh
bash ${utils_scripts}/install-components.sh jq wget

INSTALL_DIR="${HOME}/flink"
TARGET_DIR="${INSTALL_DIR}/flink-${FLINK_VERSION}"

cat > "${YSTIA_DIR}/${NODE}-service.env" << EOF
FLINK_HOME=${TARGET_DIR}
EOF


mkdir -p ${INSTALL_DIR}
log info "Downloading Flink..."
wget "${FLINK_DOWNLOAD_PATH}" -P "${INSTALL_DIR}" -N
log info "Flink downloaded successfully."
tar xzf ${INSTALL_DIR}/${FLINK_ZIP_FILE} -C ${INSTALL_DIR}
chmod +x ${TARGET_DIR}/bin/*
rm -f ${INSTALL_DIR}/${FLINK_ZIP_FILE}

setServiceInstalled

log end "Flink installed in ${INSTALL_DIR}"
