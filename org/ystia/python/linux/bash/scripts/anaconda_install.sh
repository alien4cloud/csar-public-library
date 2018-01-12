#!/usr/bin/env bash

source ${utils_scripts}/utils.sh
# To set variables for the proxy
ensure_home_var_is_set

log begin

if isServiceInstalled; then
    log end "Python component '${NODE}' already installed"
    exit 0
fi


# Prepare the installation_directory
INSTALL_DIR=$HOME

# Install bzip2 for anaconda and wget
sudo yum install -y bzip2 wget
log info "bzip2 and wget installed"

# Handle additionnal packages

if [[ -n "${REPOSITORY}" ]] && [[ "${REPOSITORY}" != "DEFAULT" ]] && [[ "${REPOSITORY}" != "null" ]]; then
  # MODE OFFLINE
  # TODO: Packages installation in offline mode is quiet strange and need some changes (See BRBDCF-287)

  # Download and install anaconda
  wget "${REPOSITORY}/Anaconda2-4.1.1-Linux-x86_64.sh" -P "$HOME" -N
  log info "Anaconda Downloaded"
  #ANACONDA_FILE="$(echo $ANACONDA_DOWNLOAD_URL | sed 's/.*\///')"
  ANACONDA_FILE="Anaconda2-4.1.1-Linux-x86_64.sh"
  bash $HOME/$ANACONDA_FILE -b -p ${INSTALL_DIR}/anaconda2
  log info "Anaconda installed"
  # Add to path
  sudo bash -c "echo 'export PATH="$INSTALL_DIR/anaconda2/bin:$PATH"' >> /etc/bashrc"
  log info "PATH edited"
  source /etc/bashrc
  # Extract additional packages
  wget "${REPOSITORY}/mespackages.tar" -P "$HOME" -N
  tar -xvf $HOME/mespackages.tar -C $HOME

  if [[ "${NLP_TWITTER}" == "true" ]]
  then
    echo y | conda install $HOME/MesPackages/conda-4.1.11-py27_0.tar.bz2
    echo y | conda install $HOME/MesPackages/conda-env-2.5.2-py27_0.tar.bz2

    echo y | conda install $HOME/MesPackages/oauthlib-0.7.2-py27_0.tar.bz2
    echo y | conda install $HOME/MesPackages/requests-oauthlib-0.4.2-py27_0.tar.bz2
    echo y | conda install $HOME/MesPackages/twython-3.2.0-py27_0.tar.bz2
    log info "nltk and twython installed"
  fi

  if [[ "${DATAVIZ}" == "true" ]]
  then
    echo y | conda install $HOME/MesPackages/conda-4.1.11-py27_0.tar.bz2
    echo y | conda install $HOME/MesPackages/conda-env-2.5.2-py27_0.tar.bz2
    # seaborn
    echo y | conda install $HOME/MesPackages/seaborn-0.7.0-py27_0.tar.bz2
    # To avoid ImportError: libXext.so.6: cannot open shared object file: No such file or directory
    sudo yum install -y python-qt4
    # plotly
    echo y | conda install $HOME/MesPackages/plotly-1.9.6-py27_0.tar.bz2
    log info "seaborn and plotly installed"
  fi

  if [[ "${DATAFORMAT}" == "true" ]]
  then
    echo y | conda install $HOME/MesPackages/conda-4.1.11-py27_0.tar.bz2
    echo y | conda install $HOME/MesPackages/conda-env-2.5.2-py27_0.tar.bz2
    # csvkit
    echo y | conda install $HOME/MesPackages/csvkit-0.9.1-py27_1.tar.bz2
    echo y | conda install $HOME/MesPackages/dbf-0.96.003-py27_0.tar.bz2
    # configparser
    echo y | conda install $HOME/MesPackages/anaconda-custom-py27_0.tar.bz2
    echo y | conda install $HOME/MesPackages/configparser-3.5.0-py27_0.tar.bz2
    log info "csvkit and configparser installed"
  fi

  if [[ "${PYBRAIN}" == "true" ]]
  then
    echo y | conda install $HOME/MesPackages/conda-4.1.11-py27_0.tar.bz2
    echo y | conda install $HOME/MesPackages/conda-env-2.5.2-py27_0.tar.bz2

    echo y | conda install $HOME/MesPackages/pybrain-0.3-py27_0.tar.bz2
    log info "pybrain installed"
  fi

else
  # MODE ONLINE

  # Download and install anaconda
  wget "http://repo.continuum.io/archive/Anaconda2-4.1.1-Linux-x86_64.sh" -P "$HOME" -N
  log info "Anaconda downloaded"
  #ANACONDA_FILE="$(echo $ANACONDA_DOWNLOAD_URL | sed 's/.*\///')"
  ANACONDA_FILE="Anaconda2-4.1.1-Linux-x86_64.sh"
  bash $HOME/$ANACONDA_FILE -b -p ${INSTALL_DIR}/anaconda2
  log info "Anaconda installed"
  # Add to path
  sudo bash -c "echo 'export PATH="$INSTALL_DIR/anaconda2/bin:$PATH"' >> /etc/bashrc"
  log info "PATH edited"
  source /etc/bashrc

  if [[ "${NLP_TWITTER}" == "true" ]]
  then
    conda install -y nltk
    conda install -y -c https://conda.anaconda.org/conda-forge twython
    log info "nltk and twython installed"
  fi

  if [[ "${DATAVIZ}" == "true" ]]
  then
    conda install -y seaborn
    conda install -y -c https://conda.anaconda.org/BjornFJohansson plotly
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
    conda install -y -c https://conda.anaconda.org/auto pybrain
    log info "pybrain installed"
  fi

fi

setServiceInstalled

log end
