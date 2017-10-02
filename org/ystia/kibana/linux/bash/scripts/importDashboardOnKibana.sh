#!/bin/bash

source ${utils_scripts}/utils.sh
log begin
ensure_home_var_is_set
source ${YSTIA_DIR}/kibana_env.sh

# Check the url parameter value validity
[[ -z "${url}" ]] && error_exit "ERROR: url parameter is required !"

log info "Import the dashboard ${url} on Kibana..."

# Dashboard file is copied under KIBANA_HOME before being imported
DB_FILE_NAME=${KIBANA_HOME}/dashboard_$$.json
if [[ "$url" == http* ]] || [[ "$url" == ftp* ]]
then
    curl -sS ${url} >${DB_FILE_NAME} || error_exit "ERROR: Cannot download  ${url}"
else
    cp ${url} ${DB_FILE_NAME} || error_exit "ERROR: Cannot copy  ${url}"
fi

# Import the dashboard
CMD_IMPORT_DB=${scripts}/import_dashboard.sh
log debug "${CMD_IMPORT_DB} ${DB_FILE_NAME}"
bash ${CMD_IMPORT_DB} ${DB_FILE_NAME}

