#!/bin/bash

source $utils_scripts/utils.sh

log begin

source $scripts/haproxy/$(get_os_distribution)/install.sh

log end
