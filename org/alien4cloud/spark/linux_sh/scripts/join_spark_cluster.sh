#!/bin/bash -e

sudo bash -c "${SPARK_INSTALL_DIR}/spark-2.2.2-bin-hadoop2.7/sbin/start-slave.sh spark://${SPARK_MASTER_ADDRESS}:${SPARK_MASTER_PORT}"
