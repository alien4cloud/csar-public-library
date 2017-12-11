#!/usr/bin/env bash
#

source ${utils_scripts}/utils.shlog begin

ensure_home_var_is_set


log info "Stopping NiFi"
sudo systemctl stop nifi.service

log end
