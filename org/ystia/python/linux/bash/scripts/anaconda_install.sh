#!/usr/bin/env bash

source ${utils_scripts}/utils.sh
# To set variables for the proxy
ensure_home_var_is_set

log begin

if isServiceInstalled; then
    log end "Python component '${NODE}' already installed"
    exit 0
fi


INSTALL_DIR=$HOME
ANACONDA_INSTALLER_NAME=Anaconda3-5.0.1-Linux-x86_64.sh
ANACONDA_DOWNLOAD_PATH=${REPOSITORY}/${ANACONDA_INSTALLER_NAME}


# Install bzip2 for anaconda and wget
sudo yum install -y bzip2 wget
log info "bzip2 and wget installed"

# Download and install anaconda
wget "${ANACONDA_DOWNLOAD_PATH}" -P "$HOME" -N
log info "Anaconda Downloaded"
bash $HOME/${ANACONDA_INSTALLER_NAME} -b -p ${INSTALL_DIR}/anaconda3
log info "Anaconda Installed"

# Add to path
sudo bash -c "echo 'export PATH="$INSTALL_DIR/anaconda3/bin:$PATH"' >> /etc/bashrc"
log info "PATH Edited"
source /etc/bashrc


setServiceInstalled
log end "Python Installed !"
