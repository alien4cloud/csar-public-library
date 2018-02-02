#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#

source ${utils_scripts}/utils.sh

log begin

sudo systemctl start flink.service

wait_for_port_to_be_open "127.0.0.1" "8081" 30  || error_exit "Cannot open port 8081"

log end "Flink JobManager started."