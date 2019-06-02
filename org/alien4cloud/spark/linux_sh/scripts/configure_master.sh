#!/bin/bash -e

echo "Configuring Spark Master: enabling REST API"

SPARK_DISTRIB=`ls ${SPARK_INSTALL_DIR} | grep -v spark.tgz`

echo "spark.master.rest.port ${SPARK_MASTER_REST_PORT}" | sudo tee ${SPARK_INSTALL_DIR}/${SPARK_DISTRIB}/conf/spark-defaults.conf > /dev/null
echo "spark.master.rest.enabled true" | sudo tee -a ${SPARK_INSTALL_DIR}/${SPARK_DISTRIB}/conf/spark-defaults.conf > /dev/null
