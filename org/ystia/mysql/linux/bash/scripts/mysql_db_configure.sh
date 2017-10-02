#!/bin/bash

source $utils_scripts/utils.sh
log begin
log info " sudo mysql -u root -p${DBMS_ROOT_PASSWORD} -e \"GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%' identified by '${DB_PASSWORD}' WITH GRANT OPTION;\" "
sudo mysql -u root -p${DBMS_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%' identified by '${DB_PASSWORD}' WITH GRANT OPTION;"
log end
