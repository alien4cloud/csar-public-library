#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#



source ${utils_scripts}/utils.sh

log begin

ensure_home_var_is_set

SERVICE_NAME=$(basename -s .yml ${beat_config})
log info "SERVICE_NAME=${SERVICE_NAME}"

sudo systemctl start ${SERVICE_NAME}.service
sleep 10
sudo systemctl is-active ${SERVICE_NAME}.service || ( echo "Failed to start ${SERVICE_NAME} !!!"; exit 1; )

log info "Beat component '${NODE}' started"
log end
