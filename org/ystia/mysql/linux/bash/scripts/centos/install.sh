#!/bin/bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


# To set variables for the proxy
source /etc/profile

# Add MySQL Community repository on CentOS
log info "Configure YUM repositories"
mysql_repo_file="/etc/yum.repos.d/mysql-community.repo"
sudo bash -c "cat $scripts/centos/mysql-community.repo > $mysql_repo_file"
sudo sed -i -e "s,MYSQL_REPO,${MYSQL_REPO},g" $mysql_repo_file

# Install MySQL community server
log info "-> install MySQL server"
sudo yum -y -d1 install mysql-community-server
