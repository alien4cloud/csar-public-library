#!/usr/bin/env bash

# Installation of packages on CentOS

echo "Using yum. Installing $@ on CentOS"

sudo yum -y install $@ || exit 2

echo "Successfully installed $@ on CentOS"

