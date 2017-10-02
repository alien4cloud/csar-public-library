#!/usr/bin/env bash

source ${utils_scripts}/utils.sh

log begin

sudo systemctl start flink.service

log end "Flink TasManager started."