#!/bin/bash

source ${utils_scripts}/utils.sh
log begin

sudo systemctl stop elasticsearch.service

log end