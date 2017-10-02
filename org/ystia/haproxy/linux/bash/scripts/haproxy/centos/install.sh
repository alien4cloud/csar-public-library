#!/bin/bash
set -e

log info "-> INSTALL HAPROXY for Centos"
sudo yum -y -d1 install haproxy
