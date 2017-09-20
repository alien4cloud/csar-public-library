#!/usr/bin/env bash

. ${utils_scripts}/utils.sh

log begin

log info "BEGIN mongo install in Centos"

# Get proxy set variables in my script
source /etc/profile

lock "install"       
  # Setup password-less ssh
  chmod +x ${scripts}/passwordless_ssh.sh
  sudo ${scripts}/passwordless_ssh.sh ${data} ${utils_scripts}

  log info "Modify and Copy MongoDB repo file"
  log info "sudo sed -i "s[replacemonurl[${MONGO_REPO}[g" ${data}/mongodb-org-3.0.repo"
  sudo sed -i "s[replacemonurl[${MONGO_REPO}[g" ${data}/mongodb-org-3.0.repo
  log info "sudo cp ${data}/mongodb-org-3.0.repo /etc/yum.repos.d/mongodb-org-3.0.repo"
  sudo cp ${data}/mongodb-org-3.0.repo /etc/yum.repos.d/mongodb-org-3.0.repo
  sudo chown root:root /etc/yum.repos.d/mongodb-org-3.0.repo
  sudo chmod 644 /etc/yum.repos.d/mongodb-org-3.0.repo
  
  # To prevent : [errno 256] no more mirrors to try
  echo -e "http_caching=packages" | sudo tee --append "/etc/yum.conf"
  
  log info "sudo -E yum install -y mongodb-org"
  sudo -E yum install -y mongodb-org
  
  # SElinux defaults to being enabled and to enforcing.
unlock "install"

log info "END mongo install"

log end 