#!/bin/bash -x

# Init
sudo yum -y update

# #################################
# ######## INSTALL DOCKER  ########
# #################################

# Remove old docker versions
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

# Install dependencies
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
 
# Setup repository
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install docker
sudo yum install  -y docker-ce-${component_version} docker-ce-cli-${component_version} containerd.io

# Verify that docker version
sudo docker --version
