#!/bin/bash -e

echo "Stopping Spark Master"

PROC=`ps -ef | grep java | grep org.apache.spark.deploy.master.Master | grep -v grep | awk -F " " '{ print $2 }'`

if [[ $PROC ]]; then
    sudo kill $PROC
    echo "Spark master stopped"
fi