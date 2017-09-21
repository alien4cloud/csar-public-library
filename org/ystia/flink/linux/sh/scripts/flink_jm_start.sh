#!/usr/bin/env bash
#
# Starlings
# Copyright (C) 2015 Bull S.A.S. - All rights reserved
#

source ${utils_scripts}/utils.sh

log begin

log info "Starting Flink JobManager"

sudo systemctl start flink.service

wait_for_port_to_be_open "127.0.0.1" "8081" 30  || error_exit "Cannot open port 8081"

log end "Flink JobManager started."