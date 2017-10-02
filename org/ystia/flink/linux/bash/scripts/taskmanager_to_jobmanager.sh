#!/usr/bin/env bash

source ${utils_scripts}/utils.sh
log begin

ensure_home_var_is_set

# Env file contains:
# FLINK_HOME: Flink installation path
source ${YSTIA_DIR}/${SOURCE_NODE}-service.env

touch ${FLINK_HOME}/.taskmanager
