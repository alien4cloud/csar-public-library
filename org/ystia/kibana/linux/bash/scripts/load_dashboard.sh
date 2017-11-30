#!/bin/bash

source ${utils_scripts}/utils.sh
log begin
ensure_home_var_is_set
source ${YSTIA_DIR}/kibana_env.sh

# Check the parameter  validity
[[ -z "${url}" ]] && [[ -z "${dashboard_file}" ]] && error_exit "ERROR: 'url' or 'dashboard_file' env. variable is required !"

# Dashboard file is downloaded or copied under KIBANA_HOME before being imported
DB_FILE_NAME=${KIBANA_HOME}/dashboard_$$.json
if [[ -n "${url}" ]]
then
    log info "Import the dashboard ${url} on Kibana..."
    curl -sS ${url} >${DB_FILE_NAME} || error_exit "ERROR: Cannot download ${url}"
else
    log info "Import the dashboard ${dashboard_file} on Kibana..."
    cp ${dashboard_file} ${DB_FILE_NAME} || error_exit "ERROR: Cannot copy ${dashboard_file}"
fi

# Import the dashboard
CMD_IMPORT_DB=${scripts}/ystia_import_dashboard.sh
log info "${CMD_IMPORT_DB} ${DB_FILE_NAME}"
bash ${CMD_IMPORT_DB} ${DB_FILE_NAME}
