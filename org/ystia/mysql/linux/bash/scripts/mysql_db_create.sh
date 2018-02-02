#!/bin/bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source $utils_scripts/utils.sh
log begin
log info "${DB_NAME} | ${DB_USER} | ${DB_PASSWORD}"
mysql -u root -p"${DBMS_ROOT_PASSWORD}" -e "CREATE DATABASE ${DB_NAME};"
mysql -u root -p"${DBMS_ROOT_PASSWORD}" -e "CREATE USER '${DB_USER}'@'%' identified by '${DB_PASSWORD}';"
log end
