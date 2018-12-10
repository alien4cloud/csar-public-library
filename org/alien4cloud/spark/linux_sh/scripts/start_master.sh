#!/bin/bash -e

echo "Starting Spark Master: advertising address ${SPARK_SLAVE_ADDRESS}"
sudo bash -c "${SPARK_INSTALL_DIR}/spark-2.2.2-bin-hadoop2.7/sbin/start-master.sh -h ${SPARK_MASTER_ADDRESS}"
