#!/bin/bash

source ${utils_scripts}/utils.sh

log begin

log info ">>>> Stopping Kafka server"
sudo systemctl stop kafka

log info ">>>> Stopping Zookeeper"
sudo systemctl stop zookeeper

log end
