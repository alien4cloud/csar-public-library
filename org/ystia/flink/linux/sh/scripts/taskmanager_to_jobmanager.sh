#!/usr/bin/env bash
#
# Starlings
# Copyright (C) 2015-2016 Bull S.A.S. - All rights reserved
#

source ${utils_scripts}/utils.sh
source ${scripts}/flink-service.properties
log begin

ensure_home_var_is_set

# Env file contains:
# FLINK_HOME: Flink installation path
source ${HOME}/.starlings/${SOURCE_NODE}-service.env

touch ${FLINK_HOME}/.taskmanager
