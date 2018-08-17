#!/bin/bash -x

# Init
sudo yum -y update
sudo yum -y install ebtables ethtool

# #################################
# ######## INSTALL DOCKER  ########
# #################################

# Install docker 1.12, the recommended version
# source: https://docs.docker.com/cs-engine/1.12/
sudo yum remove docker  \
         docker-common  \
         docker-selinux \
         docker-engine

sudo rpm --import "https://sks-keyservers.net/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e"
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://packages.docker.com/1.12/yum/repo/main/centos/7

sudo yum list docker-engine.x86_64  --showduplicates |sort -r
# The second column represents the version.
# sudo yum install docker-engine-<version>
sudo yum -y install docker-engine-1.12.6.cs13-1.el7.centos

# Verify that docker version is indeed 1.12
# sudo docker version 