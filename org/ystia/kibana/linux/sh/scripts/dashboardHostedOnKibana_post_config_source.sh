#!/bin/bash
#
# Starlings
# Copyright (C) 2015 Bull S.A.S. - All rights reserved
#

source ${utils_scripts}/utils.sh
CMD_IMPORT_DB=${scripts}/import_dashboard.sh

log begin

if [[ ! -f ${dashboard_file} ]]
then
    log info "Dashboard URL is null, so we do nothing"
    exit 0
fi

log info "$0: SOURCE_INSTANCE=${SOURCE_INSTANCE}, TARGET_INSTANCE=${TARGET_INSTANCE}, Dashboard_File=${dashboard_file}"

log debug "${CMD_IMPORT_DB} ${dashboard_file} called..."
chmod a+x ${CMD_IMPORT_DB}
${CMD_IMPORT_DB} ${dashboard_file}

