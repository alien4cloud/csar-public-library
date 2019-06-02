#!/bin/bash -e

echo "Starting Spark Master: advertising address ${SPARK_MASTER_ADDRESS}"

sudo bash -c "${SPARK_INSTALL_DIR}/spark-*/sbin/start-master.sh -h ${SPARK_MASTER_ADDRESS} --webui-port ${SPARK_UI_PORT}  -p ${SPARK_MASTER_PORT}"
