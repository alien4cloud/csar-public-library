#!/bin/bash

source $utils_scripts/utils.sh

log begin
sudo service haproxy start
log end
