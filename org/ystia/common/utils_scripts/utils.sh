#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#

# Insert file $2 in file $1 after line matching $3
# Example: insert nutch-site.conf nutch-site-mongodb.conf '<configuration>'
insert () {
    FOUND=0
    >/tmp/part1
    >/tmp/part2
    cp $1 $1.save
    cat $1.save | while read LINE
    do
        if [ $FOUND == 0 ]
        then   echo "$LINE" >>/tmp/part1
        else   echo "$LINE" >>/tmp/part2
        fi
        if echo "$LINE" | grep "$3" >/dev/null
        then    FOUND=1
        fi
    done
    cat /tmp/part1 $2 /tmp/part2 > $1
}

# Check if a port is open
# params:
#   1- host to check
#   2- port to check
# returns 0 if the port is open
is_port_open () {
    host=$1
    port=$2
    exec 6<>/dev/tcp/${host}/${port} || return 1
    exec 6>&- # close output connection
    exec 6<&- # close input connection
    return 0
}

# Wait for a command to return 0
# params:
#   1- the command to execute (using eval)
#   2- timeout in seconds (optional, defaults to 60)
#   3- check interval in seconds (optional, defaults to 5)
# returns 0 if the command succeeded within the delay
wait_for_command_to_succeed () {
    cmd=$1
    timeout=60
    interval=5
    if [[ $# -ge 2 ]] ; then
        ((timeout = $2))
    fi
    if [[ $# -ge 3 ]] ; then
        ((interval = $3))
    fi
    while ((timeout > 0)) ; do
        if eval ${cmd}
        then
            return 0
        else
            log debug "Waiting for cmd ${cmd} to success"
            sleep $interval
            (( timeout -= interval ))
        fi
    done
    return 1
}

# Wait for a port to be open
# params:
#   1- host to check
#   2- port to check
#   3- timeout in seconds (optional, defaults to 60)
#   4- check interval in seconds (optional, defaults to 5)
# returns 0 if the port is open in the delay
wait_for_port_to_be_open () {
    host=$1
    shift
    port=$1
    shift
    cmd="is_port_open ${host} ${port}"
    if wait_for_command_to_succeed "${cmd}" $@
    then
        return 0
    else
        log warning "Timeout occures while awaiting for port ${host}:${port} to be open."
        return 1
    fi
}

# Wait for a port to be open
# params:
#   1- host to ping
#   2- timeout in seconds (optional, defaults to 60)
#   3- check interval in seconds (optional, defaults to 5)
# returns 0 if the address is pingable in the delay
wait_for_address_to_be_pingable () {
    host=$1
    shift
    cmd="ping -qnc 3 ${host} > /dev/null 2>&1"
    if wait_for_command_to_succeed "${cmd}" $@
    then
        return 0
    else
        log warning "Timeout occures while awaiting for ${host} to be pingable."
        return 1
    fi
}

# Try to guess the Operating System distribution
# The guessing algorithm is:
#   1- use lsb_release retrieve the distribution name (should normally be present it's listed as requirement of VM images in installation guide)
#   2- If lsb_release is not present check if yum is present. If yes assume that we are running Centos
#   3- Otherwise check if apt-get is present. If yes assume that we are running Ubuntu
#   4- Otherwise give-up and return "unknown"
#
# Any way the returned string is in lower case.
# This function prints the result to the std output so you should use the following form to retrieve it:
# os_dist="$(get_os_distribution)"
get_os_distribution () {
    rname="unknown"
    if  [[ "$(which lsb_release)" != "" ]]
    then
        rname=$(lsb_release -si | tr [:upper:] [:lower:])
    else
        if [[ "$(which yum)" != "" ]]
        then
            # assuming we are on Centos
            rname="centos"
        elif [[ "$(which apt-get)" != "" ]]
        then
            # assuming we are on Ubuntu
            rname="ubuntu"
        fi
    fi
    echo ${rname}
}

# Try to guess the Operating System release
get_os_release () {
    if get_os_distribution | grep ubuntu > /dev/null
    then
        cat /etc/lsb-release|grep RELEASE|sed 's/.*RELEASE=//'
    elif get_os_distribution | grep centos > /dev/null
    then
        cat /etc/centos-release|sed 's/.* release //'
    fi
}

# Print an error message and exit
# params:
#   1- The error message
#   2- The exit error code (Optional: defaults to 1)
error_exit () {
    log error "${1}"
    if [[ $# -gt 1 ]]
    then
        exit ${2}
    else
        exit 1
    fi
}

# Joins a list with a given separator
# params:
#   1- The character separator
#   2- A list of elements or a bash array
function join_list {
    local IFS="$1"
    shift
    echo "$*"
}

# Deprecated as it hide the standard binary join
# Use join_list instead
function join {
    echo "Warning join as function has been deprecated in favor of join_list" >2
    join_list $@
}

# Use netstat to find a process with an open listening socket on a given port.
# The result is directly print to stdout.
# params:
#   1- the port.
get_pid_from_port () {
    sudo netstat -lnp | grep ":$1" | awk '{split($7,p,"/"); print p[1];}' | uniq
}

# Returns a list of values for a multi-evaluated attribute
# For example when using as an input param in yaml: IP_ADDRESS: { get_attribute: [SELF, ip_address] }
# Alien will generate several environment variables:
# INSTANCE will contain the local instance name
# IP_ADDRESS the local IP address
# INSTANCES a coma separated list of instances name (including the local one)
# <instance_name>_IP_ADDRESS for each instance its IP_ADDRESS attribute (including the local one)
# params:
#   1- The parameter name
#   2- Attribute Type: could be SOURCE, TARGET or SELF (optional defaults to SELF which means empty for resolution)
#   3- Exclude local instance if equals 'true' (optional default false)
get_multi_instances_attribute () {
  local param_name=$1
  local exclude_local="false"
  type=""
  if [[ $# -ge 2 ]]; then
    case "$2" in
      "SOURCE"|"TARGET")
        type="${2}_"
        ;;
      *)
        type=""
        ;;
    esac
  fi
  if [[ $# -eq 3 ]]; then
    exclude_local=$3
  fi
  for instance_name in $(eval echo \${${type}INSTANCES} | tr ',' ' '); do
    if [[ "${exclude_local}" != "true" ]] || [[ "${INSTANCE}" != "${instance_name}" ]]; then
      eval attribute=\${${instance_name}_${param_name}}
      echo "${attribute}"
    fi
  done
}

# Print a log message with the timestamp and level
# params:
#   1- Logging level (debug, info, warning, error)
#   2- Logging message
# Note: do not use ctx for now as it wont work: https://fastconnect.org/jira/browse/SUPALIEN-543
log () {
    local level=$1
    shift
    local time=$(date '+%F %R ')
    local file=$(basename $0)
    local message="$*"
    case "${level,,}" in
      begin) echo "$time INFO: $file : >>> Begin <<< $message" ;;
      end) echo "$time INFO: $file : >>> End   <<< $message" ;;
      *) echo "$time ${level^^}: $file : $message" ;;
    esac
}

# Sometimes it may happen that the $HOME variable is not properly set.
# This function retrieves the user home directory from /etc/passwd based on
# the user returned by the id command
#
ensure_home_var_is_set () {
    # First try to load /etc/profile this will also ensure that required env vars are loaded
    if [[ -f /etc/profile ]]; then
        source /etc/profile
    fi
    # If this is still not set then try with /etc/passwd
    if [[ -z "${HOME}" ]]; then
        export HOME=$(cat /etc/passwd | grep ":$(id --user):" | awk -F : '{print $6;}')
    fi
}

isServiceInstalled() {
    [ -e ${YSTIA_DIR}/.${NODE}-installFlag ]
}

setServiceInstalled() {
    touch ${YSTIA_DIR}/.${NODE}-installFlag
}

unsetServiceInstalled() {
    rm -f ${YSTIA_DIR}/.${NODE}-installFlag
}

isServiceConfigured() {
    [ -e ${YSTIA_DIR}/.${NODE}-configureFlag ]
}

setServiceConfigured() {
    touch ${YSTIA_DIR}/.${NODE}-configureFlag
}

unsetServiceConfigured() {
    rm -f ${YSTIA_DIR}/.${NODE}-configureFlag
}

isServiceStarted() {
    [ -e ${YSTIA_DIR}/.${NODE}-startFlag ]
}

setServiceStarted() {
    touch ${YSTIA_DIR}/.${NODE}-startFlag
}

unsetServiceStarted() {
    rm -f ${YSTIA_DIR}/.${NODE}-startFlag
}

# Check if a service is already configured before stopped him to avoid error
# params:
#   1- name of service to stop
stop_centos_service() {
  IS_SERVICE_ACTIVE=`sudo systemctl list-units | grep ${1} ;echo $?`
  if [[ "${IS_SERVICE_ACTIVE}" != "1" ]]; then
       echo "sudo systemctl stop firewalld"
       sudo systemctl stop firewalld
  fi
}

# Generate a fd from the file name
# TODO should be more sofisticated
getlockfd() {
    local prefix=${1}
    local count="120"
    ((count += ${#prefix}))
    echo $count
}

# take a local lock
# usage: lock name
lock() {
    local prefix=${1:-ystia}
    local fd=$(getlockfd $prefix)

    # create lock file
    local lock_file=$lock_dir/$prefix.lock
    eval "exec ${fd}>${lock_file}"

    # acquire the lock
    flock -x ${fd}
}


# release a lock previously taken
# usage: unlock name
unlock() {
    local prefix=${1:-ystia}
    local fd=$(getlockfd $prefix)

    # drop the lock
    flock -u ${fd}
}

# Get major version number from a given version string

majorVersion() {
    version=$1
    echo $(echo $version | cut -d "." -f1)
}


# Need sudo + chown on centos (not on ubuntu)
lock_dir=/var/lock/ystia
sudo mkdir -p $lock_dir
sudo chown $(id --user):$(id --group) $lock_dir

# Init log file and redirect std output to this file
# LOG_FILE may be set explicitely, or $NODE or $SOURCE_NODE will be used.
[[ ! -z ${LOG_FILE} ]] || LOG_FILE=$NODE
[[ ! -z ${LOG_FILE} ]] || LOG_FILE=$SOURCE_NODE
[[ ! -z ${LOG_FILE} ]] || LOG_FILE=ystia
log_dir="/var/log/ystia"
sudo mkdir -p $log_dir
sudo chown "$(id --user):$(id --group)" $log_dir
exec > >(tee -a "${log_dir}/${LOG_FILE}.log") 2>&1

# YSTIA_DIR
YSTIA_DIR="${HOME}/.ystia"
mkdir -p $YSTIA_DIR

# Exit on error
set -e