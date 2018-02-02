#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#

#

source ${utils_scripts}/utils.shlog begin

ensure_home_var_is_set


log info "Stopping NiFi"
sudo systemctl stop nifi.service

log end
