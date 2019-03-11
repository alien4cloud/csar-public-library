#!/bin/bash -e
source $commons/commons.sh

eval_conf_file $configs/telemetry_statsd_config.json /etc/consul/02_telemetry_config.json "STATSD_IP_ADDRESS,STATSD_PORT"
