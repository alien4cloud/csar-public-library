#!/bin/bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source $utils_scripts/utils.sh

log begin

haproxy_conf="/etc/haproxy/haproxy.cfg"

echo -e "listen stats *:1936\n \
            stats enable\n \
            stats uri /\n \
            stats hide-version\n \
            stats auth someuser:password\n" | sudo tee --append  $haproxy_conf

# Avoid SELinux issue : cannot bind socket [0.0.0.0:1936]
sudo setsebool -P haproxy_connect_any=1

log end
