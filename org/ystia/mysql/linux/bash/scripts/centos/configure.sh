#!/bin/bash

hostname=`hostname`

#Start mysql server
log info "-> first start of the mysql server"
sudo service mysqld start

# Make sure that NOBODY can access the server without a password
log info "-> change password..."
mysqladmin -u root password "${DBMS_ROOT_PASSWORD}"
mysql -u root -p"${DBMS_ROOT_PASSWORD}" -e "UPDATE mysql.user SET Password=PASSWORD('${DBMS_ROOT_PASSWORD}') WHERE User='root'"

# mysql -e "UPDATE mysql.user SET Password = PASSWORD('${DBMS_ROOT_PASSWORD}') WHERE User = 'root';"

# delete remote root user
log info "-> change remote connexion with root"
mysql -u root -p"${DBMS_ROOT_PASSWORD}" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"

# Kill the anonymous users
log info "-> delete anonymous user & various"
mysql -u root -p"${DBMS_ROOT_PASSWORD}" -e "DELETE FROM mysql.user WHERE User='';"

# Kill off the demo database
log info "-> delete test database if exists"
cmd=`mysql -u root -p"${DBMS_ROOT_PASSWORD}" -e "SHOW DATABASES;" | grep "test" | wc -l > /tmp/tmp.data`
if [ `head -n 1 /tmp/tmp.data` -eq 1 ]; then
    mysql -u root  -p"${DBMS_ROOT_PASSWORD}" -e "DROP DATABASE test;"
fi
mysql -u root -p"${DBMS_ROOT_PASSWORD}" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"

# Make our changes take effect
log info "-> commit changes and restart the mysql server"
mysql -u root -p"${DBMS_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"
# Any subsequent tries to run queries this way will get access denied because lack of usr/pwd param
sudo service mysqld stop
sudo service mysqld start

log info "-> configure mysqld to restart on reboot"
if [[ $(get_os_release) =~ ^7.* ]] ; then
    sudo systemctl enable mysqld
else
    chkconfig mysqld on
fi
