#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source ${utils_scripts}/utils.sh
source ${scripts}/logstash_utils.sh

ensure_home_var_is_set
log begin

log info "TARGET=${TARGET_NODE} SOURCE=${SOURCE_NODE}"

# Check LOGSTASH_HOME, ...
[ -z ${LOGSTASH_HOME} ] && error_exit "LOGSTASH_HOME not set"

source ${YSTIA_DIR}/${SOURCE_NODE}-service.env

log info "Remove default es output plugin"
rm $LOGSTASH_HOME/conf/*elasticsearch*.conf

log info "Copy geonames_parse.conf file to $LOGSTASH_HOME/conf"
cp ${conf}/geonames_parse.conf $LOGSTASH_HOME/conf

# Update GeoNames config file
if is_port_open "127.0.0.1" "8500"
then
    es_host_name="elasticsearch.service.ystia"
else
    es_host_name="localhost"
fi
es_port="9200"
ES_HOST=$es_host_name:$es_port

sed -i -e "s@#GEONAMES_HOME#@${GEONAMES_HOME}@g" ${LOGSTASH_HOME}/conf/geonames_parse.conf
sed -i -e "s@#FNAME#@${FNAME}@g" ${LOGSTASH_HOME}/conf/geonames_parse.conf
sed -i -e "s@#ES_HOST#@${ES_HOST}@g" ${LOGSTASH_HOME}/conf/geonames_parse.conf
sed -i -e "s@#INDEX#@${INDEX}@g" ${LOGSTASH_HOME}/conf/geonames_parse.conf

send_sighup_ifneeded

# Retain some LOGSTASH properties necessary for GeoNames (re-)configure
echo "LOGSTASH_HOME=$LOGSTASH_HOME" >> ${YSTIA_DIR}/${SOURCE_NODE}-service.env

log end
