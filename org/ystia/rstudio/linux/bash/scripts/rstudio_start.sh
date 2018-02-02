#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#



source ${utils_scripts}/utils.sh
source ${scripts}/rstudio-service.properties
log begin

log info ">>>> Check if already started"
if isServiceStarted; then
    log info "RsSudio component '${NODE}' already started"
    exit 0
fi

# Enable rjava use from rstudio
r_script_name="/tmp/get_home-$$.R"
echo "R.home()" > ${r_script_name}
r_home=$(Rscript --vanilla ${r_script_name} | grep '[1]' | sed -e 's@.*"\([^"]\+\).*@\1@g')
echo "export LD_LIBRARY_PATH=${JAVA_HOME}/jre/lib/amd64:${JAVA_HOME}/jre/lib/amd64/default" | sudo tee --append ${r_home}/etc/Renviron
#sudo rstudio-server start

# pre requisites
sudo yum -y -d1 install inotify-tools

# To set variables for the proxy
ensure_home_var_is_set

wait_for_file() {
    while sudo [ ! -d $1 ]; do
        sleep 1
    done

    while sudo [ ! -e $1/$2 ]; do
        log info "Wait for file $2 in directory $1"
        sudo inotifywait $1 -e create -q
    done
}

# args:
# $1 :package name
function install_rpackage {
    log info ">>>> Install ${1} package"
    sudo R --no-save -e "install.packages(\"${1}\")"
}

function install_rpackages {

   packages=(ade4 arules biglm boot C50 car caret combinat corrplot dplyr doSNOW e1071
             FactoMineR ff ffbase foreach foreign gbm gplots ggplot2 glmnet gmodels grplasso ipred
             kernlab lattice leaps LiblineaR lubridate MASS mice missForest nnet penalized
             plyr pROC questionr randomForest randtoolbox network RColorBrewer ROCR rpart rpart.plot
             Rserve sas7bdat shiny snow speedglm stringr tidyr tree ggvis)

   for package in ${packages[@]}
   do
       install_rpackage $package
   done

}


install_rpackages

# Need dependencies
#######################

#tm
sudo yum -y install libxml2 libxml2-devel
log info ">>>> Install tm package"
sudo R --no-save -e 'install.packages("tm")'

#RCurl
sudo yum -y install libcurl libcurl-devel
log info ">>>> Install RCurl package"
sudo R --no-save -e 'install.packages("RCurl")'

#elastic
log info ">>>> Install elastic package"
sudo R --no-save -e 'install.packages("curl")'
sudo yum -y install openssl-devel
sudo R --no-save -e 'install.packages("openssl")'
sudo R --no-save -e 'install.packages("httr")'
sudo R --no-save -e 'install.packages("elastic")'

#ploty needs httr
log info ">>>> Install plotly package"
sudo R --no-save -e 'install.packages("plotly")'

#arulesViz needs igraph and plotly
log info ">>>> Install arulesViz package"
sudo R --no-save -e 'install.packages("igraph")'
sudo R --no-save -e 'install.packages("arulesViz")'

#plsRglm needs bipartite (which needs igraph)
log info ">>>> Install plsRglm package"
sudo R --no-save -e 'install.packages("bipartite")'
sudo R --no-save -e 'install.packages("plsRglm")'

#RKlout ( need RCurl)
log info ">>>> Install RKlout package"
sudo R --no-save -e 'install.packages("RKlout")'

#twitteR
log info ">>>> Install twitteR package"
sudo R --no-save -e 'install.packages("twitteR")'

#rgl
sudo yum -y install libX11-devel
sudo yum -y install mesa-libGL-devel mesa-libGLU-devel libpng-devel
log info ">>>> Install rgl package"
sudo R --no-save -e 'install.packages("rgl")'

#extraTrees
## Mettre le composant JDK 8 avec RStudio
R CMD javareconf -e
log info ">>>> Install extraTrees package"
sudo R --no-save -e 'install.packages("extraTrees")'

#prim
log info ">>>> Install ‘prim package"
sudo R --no-save -e 'install.packages("prim")'


# Unavailable in CRAN
######################

#CHAID
#log info ">>>> Install CHAID package"
#sudo R --no-save -e 'install.packages("CHAID", repos="http://R-Forge.R-project.org")'


# TODO Will be taken into account when MapR/Hortonworks will be migrated...
#if [[ -n "${REPOSITORY}" ]] && [[ "${REPOSITORY}" != "DEFAULT" ]] && [[ "${REPOSITORY}" != "null" ]]
#then
#    RHDFS_DOWNLOAD_PATH="${REPOSITORY}/${RHDFS_ZIP_NAME}"
#    RHBASE_DOWNLOAD_PATH="${REPOSITORY}/${RHBASE_ZIP_NAME}"
#    RAVRO_DOWNLOAD_PATH="${REPOSITORY}/${RAVRO_ZIP_NAME}"
#    log info " >>>> PATHS=${RHDFS_DOWNLOAD_PATH},${RHBASE_DOWNLOAD_PATH},${RAVRO_DOWNLOAD_PATH} "
#fi

# TODO Will be taken into account when MapR/Hortonworks will be migrated...
#log info ">>>> enable rhadoop set to: ${ENABLE_RHADOOP}"
#log info ">>>> distribution set to: ${DISTRIB}"
#
#if [[ "${ENABLE_RHADOOP}" == "true" ]]; then
#
#  if [[ "${DISTRIB}" == "HortonWorks" ]]; then
#      HADOOP_DIR="/usr/hdp/2.4.0.0-169/hadoop/bin"
#  else
#      HADOOP_DIR="/opt/mapr/hadoop/hadoop-2.7.0/bin"
#  fi
#
#  log info ">>>> check for existing hadoop libraries in ${HADOOP_DIR}"
#  if [ -f "${HADOOP_DIR}/hadoop" ]  ; then
#       log info ">>>>hadoop already installed"
#  else
#       log info ">>>>Waiting for hadoop installation"
#       wait_for_file ${HADOOP_DIR} hadoop
#  fi
#
#   #RHADOOP { https://github.com/RevolutionAnalytics/RHadoop/wiki/Installing-RHadoop-on-RHEL ]
#   log info ">>>> Install RHADOOP package"
#   echo "export HADOOP_CMD=${HADOOP_DIR}/hadoop" | sudo tee --append ${r_home}/etc/Renviron
#
#   log info ">>>> hadoop_cmd=${HADOOP_DIR}/hadoop"
#   sudo R --no-save -e "install.packages(\"${RHDFS_DOWNLOAD_PATH}\", repos=NULL)"
#   sudo R --no-save -e "install.packages(\"${RAVRO_DOWNLOAD_PATH}\", repos=NULL)"
#
#   # need thirft
#   sudo yum -y install automake libtool flex bison pkgconfig gcc-c++ boost-devel libevent-devel zlib-devel python-devel ruby-devel openssl-devel
#   wget http://archive.apache.org/dist/thrift/0.8.0/thrift-0.8.0.tar.gz -O ${HOME}/thrift-0.8.0.tar.gz
#   sudo tar -xzvf ${HOME}/thrift-0.8.0.tar.gz -C ${HOME}
#   cd ${HOME}/thrift-0.8.0
#   ./configure --without-ruby --without-python
#   make
#   sudo make install
#   sudo ln -s /usr/local/lib/libthrift-0.8.0.so /usr/lib64
#   echo "export PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:/usr/local/lib/pkgconfig" | sudo tee --append ${r_home}/etc/Renviron
#   sudo sed -i 's/${prefix}\/include/${prefix}\/include\/thirft/g' /usr/local/lib/pkgconfig/thrift.pc
#   sudo make install
#   #sudo R --no-save -e 'install.packages("https://github.com/RevolutionAnalytics/rhbase/blob/master/build/rhbase_1.2.1.tar.gz?raw=true", repos=NULL)'
#   sudo R --no-save -e "install.packages(\"${RHBASE_DOWNLOAD_PATH}\", repos=NULL)"
#
#   # Not install as SparkR already provides data manipulations operations on large dataset
#   # Rcpp, RJSONIO (>= 0.8-2), digest, functional, reshape2, stringr, plyr, caTools (>= 1.16)
#   #sudo R --no-save -e 'install.packages("RJSONIO")'
#   #sudo R --no-save -e 'install.packages("functional")'
#   #sudo R --no-save -e 'install.packages("https://github.com/RevolutionAnalytics/rmr2/releases/download/3.3.1/rmr2_3.3.1.tar.gz", repos=NULL)'
#
#   # plyr, R.methodsS3, Hmisc, functional, digest, stats, memoise, lazyeval (>= 0.1), rjson
#   #sudo R --no-save -e 'install.packages("R.methodsS3")'
#   #sudo R --no-save -e 'install.packages("Hmisc")'
#   #sudo R --no-save -e 'install.packages("memoise")'
#   #sudo R --no-save -e 'install.packages("https://github.com/RevolutionAnalytics/plyrmr/releases/download/0.6.0/plyrmr_0.6.0.tar.gz", repos=NULL)'
#
#   echo "## set HADOOP_CMD globally" | sudo tee --append ${r_home}/etc/Rprofile.site
#   echo "Sys.setenv(HADOOP_CMD=\"${HADOOP_DIR}/hadoop\")" | sudo tee --append ${r_home}/etc/Rprofile.site
#
#fi

# TODO Will be taken into account when MapR/Hortonworks will be migrated...
#log info ">>>> SparkR Env set to: ${SET_SPARKR_ENV}"
#log info ">>>> distribution set to: ${DISTRIB}"
#
#if [[ "${SET_SPARKR_ENV}" == "true" ]]; then
#
#  if [[ "${DISTRIB}" == "HortonWorks" ]]; then
#      SPARK_HOME="/usr/hdp/2.4.0.0-169/spark"
#  else
#      SPARK_HOME="/opt/mapr/spark/spark-1.5.2/"
#  fi
#
#  wait_for_file ${SPARK_HOME}/bin sparkR
#
#  echo "export SPARK_HOME=${SPARK_HOME}" | sudo tee --append ${r_home}/etc/Renviron
#  echo "## set SPARK environment" | sudo tee --append ${r_home}/etc/Rprofile.site
#  echo "Sys.setenv(SPARK_HOME=\"${SPARK_HOME}\")" | sudo tee --append ${r_home}/etc/Rprofile.site
#  #echo "Sys.setenv('SPARKR_SUBMIT_ARGS'='"--master" "yarn" "sparkr-shell"')" | sudo tee --append ${r_home}/etc/Rprofile.site
#  echo ".libPaths(c(file.path(Sys.getenv(\"SPARK_HOME\"), \"R\", \"lib\"), .libPaths()))" | sudo tee --append ${r_home}/etc/Rprofile.site
#  # Avoid error about permission denied on the directory [ spark 1.5.2 - MapR 5.1 ]
#  sudo chmod 777 ${SPARK_HOME}/R/lib
#
#fi

sudo rstudio-server start
setServiceStarted

log end "RStudio started !"
