#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#

source ${utils_scripts}/utils.sh
source ${geoscripts}/utils.sh
source ${scripts}/logstash_utils.sh

ensure_home_var_is_set

log begin

# Get GEONAMES_HOME
source ${YSTIA_DIR}/${NODE}-service.env

log info "Update GeoNames index using file $FNAME"

get_geonames_from_repository $FNAME $REPOSITORY || error_exit "Cannot download $FNAME from $REPOSITORY"

# Change input with $FNAME
sed -i -e "s@data/.*txt@data/${FNAME}.txt@" ${LOGSTASH_HOME}/conf/geonames_parse.conf

send_sighup_ifneeded

log end