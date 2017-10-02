#!/usr/bin/env bash

source ${utils_scripts}/utils.sh
log begin

sudo systemctl stop logstash.service

log end