#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source ${utils_scripts}/utils.sh
log begin

source ${scripts}/logstash_utils.sh

[ -z ${LOGSTASH_HOME} ] && error_exit "LOGSTASH_HOME not set"

if config_test $LOGSTASH_HOME
then
    sudo systemctl start logstash.service
else
    return 1
fi

# Note that the launch of the twitter input is quit long...
sleep 30
sudo systemctl is-active logstash.service || ( echo "Failed to start logstash !!!"; exit 1; )

log end


