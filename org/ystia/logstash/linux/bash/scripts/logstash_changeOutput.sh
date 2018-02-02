#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source ${utils_scripts}/utils.sh
log begin

source ${scripts}/logstash_utils.sh

ensure_home_var_is_set

log info "Execute change output command with URL : $url"

replace_conf_file $LOGSTASH_HOME/conf/3-1_logstash_outputs.conf "output" $url || error_exit "Reconfiguration failed"

send_sighup_ifneeded

log end

