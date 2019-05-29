#!/bin/bash -e

echo "Starting Spark Worker: advertising address ${SPARK_WORKER_ADDRESS}, master: spark://${SPARK_MASTER_ADDRESS}:${SPARK_MASTER_PORT}"
sudo bash -c "${SPARK_INSTALL_DIR}/spark-*/sbin/start-slave.sh -h ${SPARK_WORKER_ADDRESS} spark://${SPARK_MASTER_ADDRESS}:${SPARK_MASTER_PORT}"
