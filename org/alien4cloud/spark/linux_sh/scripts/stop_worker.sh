#!/bin/bash -e

echo "Stopping Spark Worker"

PROC=`ps -ef | grep java | grep org.apache.spark.deploy.worker.Worker | grep -v grep | awk -F " " '{ print $2 }'`

if [[ $PROC ]]; then
    sudo kill $PROC
    echo "Spark master stopped"
fi
