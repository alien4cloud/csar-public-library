#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#



source ${utils_scripts}/utils.sh
# To set variables for the proxy
ensure_home_var_is_set

log begin

source /etc/bashrc


if isServiceInstalled; then
  echo "Jupyter component already installed"
  exit 0
fi

ENV_JUPYTER_FILE=$HOME/.jupyter/ystia_env4jupyter.sh

sudo yum install -y wget

jupyter notebook --generate-config
echo "c.NotebookApp.ip = '*'" >> $HOME/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.open_browser = False" >> $HOME/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.port = 9888" >> $HOME/.jupyter/jupyter_notebook_config.py
# TODO find a way to manage security
echo "c.NotebookApp.token = ''" >> $HOME/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.password = ''" >> $HOME/.jupyter/jupyter_notebook_config.py


# Configure default directory for notebooks storage
mkdir $HOME/MyNotebooks
echo "c.NotebookApp.notebook_dir='"$HOME/MyNotebooks"'" >> $HOME/.jupyter/jupyter_notebook_config.py


if [[ "${IRKERNEL}" == "true" ]]
then
  #base
  sudo yum install -y libzmq3-dev python-zmq
  sudo yum install -y zeromq-devel
  #gitr2 error donc pas devtools
  sudo yum install -y openssl-devel
  sudo yum install -y czmq-devel
  #Unable to find the LibSSH2 library on this mais pas d'erreur
  sudo yum install -y libssh2-devel
  #curl
  sudo yum install -y libcurl-devel

  log info "R installation"
  sudo yum install -y R
  log info "R is installed"
  #install dans  nouvelle library
  sudo bash -c "echo 'export LD_LIBRARY_PATH="/lib/:/lib64/:/usr/lib64/:/usr/lib64/R/lib:$HOME/anaconda2/lib"' >> /etc/bashrc"
  #Fix issue BRBDCF-466
  mkdir -p $HOME/R/x86_64-redhat-linux-gnu-library/3.3
  echo "R_LIBS=$HOME/R/x86_64-redhat-linux-gnu-library/3.3" >>${ENV_JUPYTER_FILE}

  #get the export before Rscript
  source /etc/bashrc
  log info "add new library"
  Rscript ${data_file}/packJup.R

  log info "irkernel installed"
fi

if [[ "${PY35KERNEL}" == "true" ]]
then
  echo y | conda create -n py35 python=3.5 anaconda
  log info "env for python35 created"
  source activate py35
  #otherwise permission denied
  sudo bash -c 'source /etc/bashrc; ipython kernel install'
  source deactivate
  # To see py35 in the 'New' menu of Notebook
  # Cf https://stackoverflow.com/questions/30492623/using-both-python-2-x-and-python-3-x-in-ipython-notebook
  cp -r $HOME/anaconda2/envs/py35/share/jupyter/kernels/python3 $HOME/anaconda2/share/jupyter/kernels
  log info "py35 kernel installed"
fi


# TODO Will be taken into account when MapR/Hortonworks will be migrated...
if [[ "${SPARK_KERNEL}" == "true" ]]
then

  #MODE OFFLINE
  if [[ -n "${REPOSITORY}" ]] && [[ "${REPOSITORY}" != "DEFAULT" ]] && [[ "${REPOSITORY}" != "null" ]]; then
    #download and install anaconda

    cd $HOME
    wget "${REPOSITORY}/spark-1.5.2-bin-hadoop2.6.tgz" -P "$HOME" -N
    tar zxvf spark-1.5.2-bin-hadoop2.6.tgz
    log info "spark installed"

    wget "${REPOSITORY}/spark-kernel-0.1.5-SNAPSHOT.tar.gz" -P "$HOME" -N
    tar zxvf spark-kernel-0.1.5-SNAPSHOT.tar.gz
    log info "spark-kernel downloaded"

    sudo yum install -y java
    log info "java installed"

    mkdir -p ~/.ipython/kernels/spark
    cp -r spark-kernel ~/.ipython/kernels/spark/
    cd ~/.ipython/kernels/spark/

  else
    #MODE ONLINE
    cd $HOME
    wget "http://d3kbcqa49mib13.cloudfront.net/spark-1.5.2-bin-hadoop2.6.tgz" -P "$HOME" -N
    tar zxvf spark-1.5.2-bin-hadoop2.6.tgz
    log info "spark installed"

    git clone https://github.com/ibm-et/spark-kernel.git

    log info "spark-kernel downloaded"

    cd spark-kernel
    export APACHE_SPARK_VERSION=1.5.2

    curl https://bintray.com/sbt/rpm/rpm | sudo tee /etc/yum.repos.d/bintray-sbt-rpm.repo
    sudo yum install -y sbt
    log info "sbt installed"

    make dist
    log info "make dist"


    mkdir -p ~/.ipython/kernels/spark
    cp -r dist/spark-kernel ~/.ipython/kernels/spark/
    cd ~/.ipython/kernels/spark/

  fi
  #delete the last 3 lines
  head -n -3 ./spark-kernel/bin/spark-kernel > tmp.txt; rm -f ./spark-kernel/bin/spark-kernel; mv tmp.txt ./spark-kernel/bin/spark-kernel

  echo 'exec "$SPARK_HOME"/bin/spark-submit \
  ${SPARK_OPTS} \
  --driver-class-path $PROG_HOME/lib/${KERNEL_ASSEMBLY} \
  --class com.ibm.spark.SparkKernel $PROG_HOME/lib/${KERNEL_ASSEMBLY} "$@"
  ' >> ./spark-kernel/bin/spark-kernel

  echo "{
    \"display_name\": \"Spark\",
    \"language_info\": { \"name\": \"scala\" },
    \"argv\": [
    \"$HOME/.ipython/kernels/spark/spark-kernel/bin/spark-kernel\",
    \"--master\",
    \"yarn-client\",
    \"--profile\",
    \"{connection_file}\"
    ],
    \"codemirror_mode\": \"scala\",
    \"env\": {
      \"SPARK_OPTS\": \"--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=trace\",
      \"MAX_INTERPRETER_THREADS\": \"16\",
      \"SPARK_CONFIGURATION\": \"spark.cores.max=4\",
      \"CAPTURE_STANDARD_OUT\": \"true\",
      \"CAPTURE_STANDARD_ERR\": \"true\",
      \"SEND_EMPTY_OUTPUT\": \"false\",
      \"SPARK_HOME\": \"$HOME/spark-1.5.2-bin-hadoop2.6\",
      \"PYTHONPATH\": \"$HOME/spark-1.5.2-bin-hadoop2.6/python:$HOME/spark-1.5.2-bin-hadoop2.6/python/lib/py4j-0.9-src.zip\"
    }
  }" > ~/.ipython/kernels/spark/kernel.json

  # otherwise permision denied with jupyter notebook
  sudo chmod 751 -R $HOME/.ipython

fi


# TODO Will be taken into account when H2O will be migrated...
if [[ "${H2O}" == "true" ]]
then
  conda install -y requests
  conda install -y tabulate
  conda install -y scikit-learn
  conda install -y colorama
  conda install -y future
  log info "env for h2o created"
  conda install -y h2o h2o-py
  log info "h2o installed"
fi

# Take into account proxy
[[ -r /etc/profile.d/proxy.sh ]] && (cat /etc/profile.d/proxy.sh | sed -e "s|export||" >>${ENV_JUPYTER_FILE})
# Setup systemd service
sudo cp ${scripts}/systemd/jupyter.service /etc/systemd/system/jupyter.service
sudo sed -i -e "s/{{USER}}/${USER}/g" -e "s@{{CMD_JUPYTER}}@$(which jupyter)@g" /etc/systemd/system/jupyter.service
if [[ -r ${ENV_JUPYTER_FILE} ]]
then
  sudo sed -i -e "s@{{ENVIRONMENTFILE}}@EnvironmentFile=${ENV_JUPYTER_FILE}@g" /etc/systemd/system/jupyter.service
else
  sudo sed -i -e "s@{{ENVIRONMENTFILE}}@@g" /etc/systemd/system/jupyter.service
fi
sudo systemctl daemon-reload
#sudo systemctl enable jupyter.service


setServiceInstalled

log end "Jupyter installed !"
