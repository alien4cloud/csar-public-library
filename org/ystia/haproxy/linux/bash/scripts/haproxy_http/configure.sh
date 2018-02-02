#!/bin/bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source $utils_scripts/utils.sh

log begin

log info "hostname=${HOSTNAME}"
haproxy_conf="/etc/haproxy/haproxy.cfg"
sudo cp $scripts/haproxy_http/files/haproxy-part.cfg /tmp/${NODE}-haproxy-part.cfg
sudo chmod +w /tmp/${NODE}-haproxy-part.cfg
sudo sed -i -e "s/NodeName/${NODE}/g" /tmp/${NODE}-haproxy-part.cfg
sudo sed -i -e "s/PORT/${PORT}/g" /tmp/${NODE}-haproxy-part.cfg
cat /tmp/${NODE}-haproxy-part.cfg | sudo tee --append $haproxy_conf

log end
