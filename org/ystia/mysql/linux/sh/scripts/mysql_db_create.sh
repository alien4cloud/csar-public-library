#!/bin/bash

source $utils_scripts/utils.sh
log begin
log info "${DB_NAME} | ${DB_USER} | ${DB_PASSWORD}"
mysql -u root -p"${DBMS_ROOT_PASSWORD}" -e "CREATE DATABASE ${DB_NAME};"
mysql -u root -p"${DBMS_ROOT_PASSWORD}" -e "CREATE USER '${DB_USER}'@'%' identified by '${DB_PASSWORD}';"
log end
