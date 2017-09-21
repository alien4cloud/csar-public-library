#!/usr/bin/env bash

#
# Starlings
# Copyright (C) 2015 Bull S.A.S. - All rights reserved
#

source ${utils_scripts}/utils.sh
log begin

log info "Stopping Flink"

sudo systemctl stop flink.service

log end "Flink stopped."
