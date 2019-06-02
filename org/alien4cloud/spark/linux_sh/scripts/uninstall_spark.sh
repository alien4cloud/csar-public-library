#!/bin/bash -e

PROC=`ps -ef | grep java | grep org.apache.spark | grep -v grep | awk -F " " '{ print $2 }'`

if [[ $PROC ]]; then
    echo "Not uninstalling spark as one process is still running"
else
  sudo /bin/rm -Rf /tmp/spark-events
  sudo /bin/rm -Rf ${SPARK_INSTALL_DIR}
  echp "Spark uninstalled"
fi
