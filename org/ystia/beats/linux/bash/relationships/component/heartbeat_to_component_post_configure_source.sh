#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#


source ${utils_scripts}/utils.sh


log begin

ensure_home_var_is_set
lock "$(basename $0)"
# Ensure that we will release the lock whatever may happen
trap "unlock $(basename $0)" EXIT


install_dir=${HOME}/${SOURCE_NODE}
config_file=${install_dir}/*beat.yml

#check if running_services' file already exists
if [[ ! -e "${install_dir}/running_services.txt" ]]; then
    touch ${install_dir}/running_services.txt
fi
if [[ ! -e "${install_dir}/running_computes.txt" ]]; then
    touch ${install_dir}/running_computes.txt
fi

#install "jq" to parse json
if [[ ! -n $(which jq) ]]
then
	source /etc/profile
	bash ${utils_scripts}/install-components.sh "jq" 
	#sudo yum -y install jq 
fi

touch ${install_dir}/tmp_services.json
curl -s  http://localhost:8500/v1/catalog/services > ${install_dir}/tmp_services.json

#get number of components in consul
count=$( jq '. | length' ${install_dir}/tmp_services.json)

#for each component, save the name and get his ip/port 

#add the ip/port in heartbeat's yaml file (http config)
flag=false

for((i=0;i<$count;i++))
do
	key="$(cat ${install_dir}/tmp_services.json | jq '.|keys['${i}']')"
 	key=$(echo "$key" | tr -d '"')
	if ! grep -Fxq $key ${install_dir}/running_services.txt
	then
	    echo $key >> ${install_dir}/running_services.txt
	    service_data=$(curl -s  http://localhost:8500/v1/catalog/service/$key) 
	    service=$(echo $service_data |jq '.[]|.Address?' | tr -d '"')
	    service_array=($service)
	    port=$(echo $service_data |jq '.[]|.ServicePort?')
	    port=($port)
	    for elt in ${service_array[@]}
	    do
	    	echo "executing sed for $elt and port $port.."
 			sudo sed -i -e "s/urls: \[/&\"http:\/\/$elt:$port\",/" ${config_file}
 			if ! grep -Fxq $elt ${install_dir}/running_computes.txt
 			then
 				echo $elt >> ${install_dir}/running_computes.txt
 			fi
 	    done
 		log info "Component $key has been added to heartbeat yaml file"
 		#if [[ $key = "elasticsearch" ]]; then
 		#	sed -i -e "s/hosts: \[\"localhost:9200/hosts: \[\"$service:9200/g" ${config_file}
 		#fi
 		flag=true

 		
	fi

done

#add the hosts to tcp and icmp config
if [[ $flag ]]; then
	hosts=$(sudo grep urls:.* ${config_file} |sed 's/#  urls/hosts/g'  | sed 's/http:\/\///g' |sed 's/,\"localhost:0000\"//g'| sed -e 's/^[[:space:]]*//')
	sudo sed  -i -e "/  #TCP_HOSTS_PLACEHOLDER#/!b;n;c\ \ ${hosts}" ${config_file}
	computes=(`cat "${install_dir}/running_computes.txt"`)
	icmp_computes="hosts: [\"${computes[0]}\""
	for i in "${computes[@]:1}"
	do
		icmp_computes=$icmp_computes",\"$i\""
	done
	icmp_computes=$icmp_computes"]"
	sudo sed  -i -e "/  #ICMP_HOSTS_PLACEHOLDER#/!b;n;c\ \ ${icmp_computes}" ${config_file}
	flag=false
fi

#set root as owner for the config file
sudo chown root ${config_file}

rm ${install_dir}/tmp_services.json
log end
