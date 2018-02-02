#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#

source ${utils_scripts}/utils.sh
log begin

source ${lsscripts}/logstash_utils.sh

ensure_home_var_is_set

# get LOGSTASH_HOME
source ${YSTIA_DIR}/${HOST}-service.env

log info "Update Twitter languages property by adding value(s) in the array: "
log info "    languages: ${languages}"

# Reconfigure languages property
add_values_in_array_property $LOGSTASH_HOME/conf/1-${NODE}_logstash_inputs.conf "languages" "${languages}" || error_exit "Reconfiguration failed"

send_sighup_ifneeded

log end