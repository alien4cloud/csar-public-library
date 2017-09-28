#!/bin/bash

source $utils_scripts/utils.sh

log begin
sudo service haproxy reload
log end
