#!/bin/bash
#
# Starlings
# Copyright (C) 2016 Bull S.A.S. - All rights reserved
#

source ${utils_scripts}/utils.sh
log begin

# To set variables for the proxy
ensure_home_var_is_set

sudo systemctl start cloudera-scm-agent
# TODO Check the agent is running

log end
