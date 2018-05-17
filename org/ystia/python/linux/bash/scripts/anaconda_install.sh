#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


function install_pkg_in_mode_off() {
    REPO=$1
    PKG=$2
    cd $HOME
    wget ${REPO}/${PKG}
    conda install -y ${PKG}
    rm -f ${PKG}
    log info ">>>> Conda Package '${PKG}' installed"

}

source ${utils_scripts}/utils.sh
# To set variables for the proxy
ensure_home_var_is_set

log begin

if isServiceInstalled; then
    log end "Python component '${NODE}' already installed"
    exit 0
fi


INSTALL_DIR=$HOME/anaconda2
ANACONDA_INSTALLER_NAME="Anaconda2-5.1.0-Linux-x86_64.sh"


# Install bzip2 for anaconda and wget
sudo yum install -y bzip2 wget
log info "bzip2 and wget installed"


if [[ -n "${REPOSITORY}" ]] && [[ "${REPOSITORY}" != "DEFAULT" ]] && [[ "${REPOSITORY}" != "null" ]]; then
    # MODE OFFLINE
    ANACONDA_DOWNLOAD_PATH=${REPOSITORY}/${ANACONDA_INSTALLER_NAME}
else
    # MODE ONLINE
    ANACONDA_DOWNLOAD_PATH="http://repo.continuum.io/archive/${ANACONDA_INSTALLER_NAME}"
fi
# Download and install anaconda
wget "${ANACONDA_DOWNLOAD_PATH}" -P "$HOME" -N
log info "Anaconda Downloaded from ${ANACONDA_DOWNLOAD_PATH}"
bash $HOME/${ANACONDA_INSTALLER_NAME} -b -p ${INSTALL_DIR}
log info "Anaconda Installed"
# Add to path
sudo bash -c "echo 'export PATH="$INSTALL_DIR/bin:$PATH"' >> /etc/bashrc"
log info "PATH Edited"
source /etc/bashrc


if [[ -n "${REPOSITORY}" ]] && [[ "${REPOSITORY}" != "DEFAULT" ]] && [[ "${REPOSITORY}" != "null" ]]; then
    # MODE OFFLINE

    if [[ "${NLP_TWITTER}" == "true" ]]
    then
        for PACKAGE in oauthlib-2.0.6-py_0.tar.bz2 requests-oauthlib-0.8.0-py27_1.tar.bz2 nltk-3.2.5-py27hec5f4de_0.tar.bz2 twython-3.6.0-py27_0.tar.bz2
        do
            install_pkg_in_mode_off ${REPOSITORY} ${PACKAGE}
        done
        log info "nltk and twython installed"
    fi

    if [[ "${DATAVIZ}" == "true" ]]
    then
        sudo yum install -y python-qt4
        for PACKAGE in seaborn-0.8.1-py27_0.tar.bz2 plotly-2.4.1-py27_0.tar.bz2
        do
            install_pkg_in_mode_off ${REPOSITORY} ${PACKAGE}
        done
        log info "seaborn and plotly installed"
    fi

    if [[ "${DATAFORMAT}" == "true" ]]
    then
        for PACKAGE in csvkit-1.0.3-py27_0.tar.bz2 configparser-3.5.0b2-py27_0.tar.bz2
        do
            install_pkg_in_mode_off ${REPOSITORY} ${PACKAGE}
        done
        log info "csvkit and configparser installed"
    fi

    if [[ "${PYBRAIN}" == "true" ]]
    then
        install_pkg_in_mode_off ${REPOSITORY} pybrain-0.3.3-py27_0.tar.bz2
        log info "pybrain installed"
    fi

    if [[ "${ML}" == "true" ]]
    then
        for PACKAGE in pandas-0.23.0-py27h637b7d7_0.tar.bz2 scikit-learn-0.19.1-py27_nomklh6479e79_0.tar.bz2
        do
            install_pkg_in_mode_off ${REPOSITORY} ${PACKAGE}
        done

        log info "pandas and scikit-learn installed"
    fi

else
    # MODE ONLINE

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
        # To avoid ImportError: libXext.so.6: cannot open shared object file: No such file or directory
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

    if [[ "${ML}" == "true" ]]
    then
        conda install -y pandas
        log info "pandas installed"

        conda install -y scikit-learn
        log info "scikit-learn installed"
    fi
fi


setServiceInstalled
log end "Python Installed !"
