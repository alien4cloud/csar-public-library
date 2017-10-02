#!/bin/bash

device=$1
file='/tmp/mysql_device'
log info "-> Disk Location : $device"
echo $device > $file
if [ -n "$device"  ]; then
    mountPoint=$(df -h | grep $device | awk '{print $NF}')
    mysqlData="$mountPoint/mysql/data"
    mysqlLog="$mountPoint/mysql/log"
    mysqlConf="/etc/my.cnf"

    #Stop mysql
    log info "stopping mysql"
    sudo service mysqld stop

    #Disable SELinux
    setenforce 0

    #Copy mysql data
    mkdir -p $mysqlData
    chown mysql:mysql $mysqlData
    mv /var/lib/mysql/* $mysqlData

    #Change mysql configuration
    sed -i -e 's#datadir=.*#datadir='$mysqlData'#' $mysqlConf
    sed -i -e 's/socket/#socket/' $mysqlConf
    echo "[client]" >> $mysqlConf
    echo "socket="$mysqlData"/mysql.sock" >> $mysqlConf

    #Copy mysql log
    mkdir -p $mysqlLog
    chown mysql:mysql $mysqlLog
    mv /var/log/mysqld.log $mysqlLog
    sed -i -e 's#log-error=.*#log-error='$mysqlLog'/mysqld.log#' $mysqlConf

    #Start mysql
    log info "starting mysql"
    sudo service mysqld start
fi
