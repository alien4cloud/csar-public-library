#!/bin/bash -x

# get aws credentials
# for line in $(cat /home/ubuntu/.aws/config) ; do
#   if [ "$line" != "[default]" ] ; then
#   export $line
#   fi
# done
if [ -z "${ES_INIT_FILE}" ] &&  [ -z "${ES_INIT_FILE}" ]; then
  echo "init files are empty"
else

user=$(whoami)

# script to restore elasticsearch and alien4cloud
A4C_CONFIG="/opt/alien4cloud/alien4cloud/config/alien4cloud-config.yml"

# Elasticsear IP adress
ES_IP=$(cat ${A4C_CONFIG} | grep "hosts: " | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])')

# Initiate ES
ES_SNAPSHOT_DIR=${ES_INIT_FILE}
ES_SNAPSHOT_NAME=${ES_INIT_FILE}

# setup elastic search snapshot repository
echo "initiate snapshot repo"

curl -s -XPUT "${ES_IP}:9200/_snapshot/es_backup/" -d '{
     "type": "s3",
       "settings": {
     "access_key": "'$AWS_ACCESS_KEY'",
     "secret_key": "'$AWS_SECRET_KEY'",
         "bucket": "a4c-demo",
         "region": "'$REGION'",
         "base_path": "'$ES_SNAPSHOT_DIR'"
  }
}' > /dev/null

# close indexes before restore operation
echo "close all indices"
curl -s -XPOST "${ES_IP}:9200/_all/_close"  > /dev/null

# trigger elastic search data restore
echo "restore snapshot"
# curl -s -XPOST "${ES_IP}:9200/_snapshot/es_backup/$ES_SNAPSHOT_NAME/_restore"
RESULT=`curl -s -XPOST "$ES_IP:9200/_snapshot/es_backup/$ES_SNAPSHOT_NAME/_restore?pretty" -d '{
  "indices": "csargitrepository,deploymentinputs,deploymentmatchingconfiguration,topology,alienaudit,group,plugin,toscaelement,serviceresource,pluginconfiguration,promotionrequest,a4cdinstancereport,csar,paasdeploymentlog,maintenancemodestate,suggestion,applicationenvironment,metapropconfiguration,imagedata,dataobjectversion,deployment,logclientregistration,dashboardsnapshotinformations,repository,applicationversion,deploymentmonitorevents,deployedtopologies,user,application"
}'` >> /tmp/restore_log

# SUCCESS=$(echo "$RESULT" | grep "\"shards\":{\"total\":29,\"failed\":0,\"successful\":29}")
# echo "snapshot elasticsearch $RESULT"

# if [ -z "$SUCCESS" ]; then
#   echo "Failed to restore Elastic Search"
#   echo $RESULT
#   exit 1
# else
curl -s -XPOST "${ES_IP}:9200/_all/_open"  > /dev/null
# Restore A4C node
echo "Please, consider turning Alien4Cloud off before you restore a backup."
sudo /etc/init.d/alien stop

ALIEN_DIR="/opt/alien4cloud/"
mkdir -p /home/$user/archives
# Get the archive file from S3 repository
echo "Download archive file from S3"
aws s3 cp --profile demo ${S3_URL}/${ALIEN_INIT_FILE}.tar.gz /home/$user/archives

# Extract Archive
echo "extract snapshot"
tar xf /home/$user/archives/${ALIEN_INIT_FILE}.tar.gz -C /home/$user/archives

# Copy file system data
echo "copy runtime"
sudo rm -rf ${DATA_DIR}/*
sudo cp -Rf /home/$user/archives/${ALIEN_INIT_FILE}/* ${DATA_DIR}

echo "start alien"
cd /home/${user}
sudo /etc/init.d/alien start
fi
