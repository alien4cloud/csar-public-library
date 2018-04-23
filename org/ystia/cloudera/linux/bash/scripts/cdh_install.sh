#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#

source ${scripts}/cloudera.properties

if [[ -z "${CDH_REPO}" ]] || [[ "${CDH_REPO}" == "DEFAULT" ]] || [[ "${CDH_REPO}" == "null" ]]; then
    CDH_REPO=${CDH_DEFAULT_REPO}
fi

log info "CDH repository is ${CDH_REPO}"

log info "Building yum repo file for CDH"
cat ${data}/cloudera-cdh5.repo |
sed "s|@CDH_REPO@|${CDH_REPO}|g" >/tmp/cloudera-cdh5.repo
sudo cp /tmp/cloudera-cdh5.repo /etc/yum.repos.d

log info "Installing CDH"
# TODO ajouter Supervisord? hbase_indexer? keytrustee_kp? keytrustee_server?
bash ${utils_scripts}/install-components.sh "hadoop-[a-zA-Z]* hive hbase hbase-solr-indexer oozie hue sqoop2 flume zookeeper impala impala-shell crunch llama"

# Configure the init scripts to not start on boot
# Cf http://www.cloudera.com/documentation/enterprise/latest/topics/cm_ig_install_path_b.html#id_znh_q4m_25
sudo systemctl disable hadoop-hdfs-datanode
sudo systemctl disable hadoop-hdfs-journalnode
sudo systemctl disable hadoop-hdfs-namenode
sudo systemctl disable hadoop-hdfs-nfs3
sudo systemctl disable hadoop-hdfs-secondarynamenode
sudo systemctl disable hadoop-hdfs-zkfc
sudo systemctl disable hadoop-httpfs
sudo systemctl disable hadoop-kms-server
sudo systemctl disable hadoop-mapreduce-historyserver
sudo systemctl disable hadoop-yarn-nodemanager
sudo systemctl disable hadoop-yarn-proxyserver
sudo systemctl disable hadoop-yarn-resourcemanager
sudo systemctl disable hue
sudo systemctl disable oozie
sudo systemctl disable hbase-solr-indexer

log info "CDH sucessfully installed"

log info "Building yum repo file for Kafka"

if [[ -z "${KAFKA_REPO}" ]] || [[ "${KAFKA_REPO}" == "DEFAULT" ]] || [[ "${KAFKA_REPO}" == "null" ]]; then
    KAFKA_REPO=${KAFKA_DEFAULT_REPO}
fi

cat ${data}/kafka.repo |
sed "s|@KAFKA_REPO@|${KAFKA_REPO}|g" >/tmp/kafka.repo
sudo cp /tmp/kafka.repo /etc/yum.repos.d

log info "Installing Kafka"
bash ${utils_scripts}/install-components.sh "kafka kafka-server"

log info "Kafka sucessfully installed"


