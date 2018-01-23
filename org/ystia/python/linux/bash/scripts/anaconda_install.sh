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


# Install bzip2 for anaconda and wget
sudo yum install -y bzip2 wget
log info "bzip2 and wget installed"


if [[ -n "${REPOSITORY}" ]] && [[ "${REPOSITORY}" != "DEFAULT" ]] && [[ "${REPOSITORY}" != "null" ]]; then
    # MODE OFFLINE
    # TODO ....
    log info "TODO: ........"
else
    # MODE ONLINE
    # Download and install anaconda
    REPOSITORY="http://repo.continuum.io/archive"
    ANACONDA_INSTALLER_NAME="Anaconda2-5.0.1-Linux-x86_64.sh"
    ANACONDA_DOWNLOAD_PATH=${REPOSITORY}/${ANACONDA_INSTALLER_NAME}
    wget "${ANACONDA_DOWNLOAD_PATH}" -P "$HOME" -N
    log info "Anaconda Downloaded"
    bash $HOME/${ANACONDA_INSTALLER_NAME} -b -p ${INSTALL_DIR}/anaconda2
    log info "Anaconda Installed"
    # Add to path
    sudo bash -c "echo 'export PATH="$INSTALL_DIR/anaconda2/bin:$PATH"' >> /etc/bashrc"
    log info "PATH Edited"
    source /etc/bashrc

    if [[ "${NLP_TWITTER}" == "true" ]]
    then
      conda install -y nltk
      conda install -y -c conda-forge twython
      log info "nltk and twython installed"
    fi

    if [[ "${DATAVIZ}" == "true" ]]
    then
      conda install -y seaborn
      conda install -y plotly
      sudo yum install -y python-qt4
      log info "seaborn and plotly installed"
    fi

    if [[ "${DATAFORMAT}" == "true" ]]
    then
      conda install -y csvkit
      conda install -y configparser
      log info "csvkit and configparser installed"
    fi

    if [[ "${PYBRAIN}" == "true" ]]
    then
      conda install -y -c mq pybrain
      log info "pybrain installed"
    fi

fi


setServiceInstalled
log end "Python Installed !"
