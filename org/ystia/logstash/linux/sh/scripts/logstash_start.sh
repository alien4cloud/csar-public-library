#!/usr/bin/env bash
#
# Starlings
# Copyright (C) 2015 Bull S.A.S. - All rights reserved
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


