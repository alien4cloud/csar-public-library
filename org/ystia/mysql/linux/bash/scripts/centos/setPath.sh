#!/bin/bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


device=$1
file='/tmp/mysql_device'
log info "-> Disk Location : $device"
echo $device > $file
if [ -n "$device"  ]; then
    mountPoint=$(df -h | grep $device | awk '{print $NF}')
    mysqlData="$mountPoint/mysql/data"
    mysqlLog="$mountPoint/mysql/log"
    mysqlConf="/etc/my.cnf"

    # Stop mysql
    log info "stopping mysql"
    sudo service mysqld stop

    #Disable SELinux
    sudo setenforce 0

    # Copy mysql data
    sudo mkdir -p $mysqlData
    sudo chown mysql:mysql $mysqlData
    sudo mv /var/lib/mysql/* $mysqlData

    # Change mysql configuration
    sudo sed -i -e 's#datadir=.*#datadir='$mysqlData'#' $mysqlConf
    sudo sed -i -e 's/socket/#socket/' $mysqlConf
    sudo sh -c "echo "[client]" >> $mysqlConf"
    sudo sh -c "echo "socket=$mysqlData/mysql.sock" >> $mysqlConf"

    # Copy mysql log
    sudo mkdir -p $mysqlLog
    sudo chown mysql:mysql $mysqlLog
    sudo mv /var/log/mysqld.log $mysqlLog
    sudo sed -i -e 's#log-error=.*#log-error='$mysqlLog'/mysqld.log#' $mysqlConf

    # Start mysql
    log info "starting mysql"
    sudo service mysqld start
fi
