#!/usr/bin/env bash

source ${utils_scripts}/utils.sh
log begin

log info "Stopping Flink"

sudo systemctl stop flink.service

log end "Flink stopped."
