#!/bin/bash

# To set variables for the proxy
source /etc/profile

# Add MySQL Community repository on CentOS
log info "Configure YUM repositories"
mysql_repo_file="/etc/yum.repos.d/mysql-community.repo"
sudo bash -c "cat $scripts/centos/mysql-community.repo > $mysql_repo_file"
sudo sed -i -e "s,MYSQL_COMMUNITY_REPO,${MYSQL_COMMUNITY_REPO},g" $mysql_repo_file

# Install MySQL community server
log info "-> install MySQL server"
sudo yum -y -d1 install mysql-community-server
