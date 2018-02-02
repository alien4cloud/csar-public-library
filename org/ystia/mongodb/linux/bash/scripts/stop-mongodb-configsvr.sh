#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


. ${utils_scripts}/utils.sh
log begin

log info "BEGIN mongo stop"

log info "systemctl stop mongod"

sudo systemctl stop mongod
sudo systemctl status mongod

log info "END service mongo stop"

log end
