#!/bin/bash -e

echo "Starting Spark Slave: advertising address ${SPARK_SLAVE_ADDRESS}, master: spark://${SPARK_MASTER_ADDRESS}:${SPARK_MASTER_PORT}"
sudo bash -c "${SPARK_INSTALL_DIR}/spark-*/sbin/start-slave.sh -h ${SPARK_SLAVE_ADDRESS} spark://${SPARK_MASTER_ADDRESS}:${SPARK_MASTER_PORT}"
