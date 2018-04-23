#!/usr/bin/env bash
#
# Ystia Forge
# Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.
# Use of this source code is governed by Apache 2 LICENSE that can be found in the LICENSE file.
#

source ${scripts}/cloudera.properties

# Prevent interference between ClouderaServer and ClouderaAgent installation
lock "cloudera_prepare_host"
PREPARE_HOST_IS_DONE=${YSTIA_DIR}/.cloudera-prepareHostFlag
# Already Done ?
if [ -e  ${PREPARE_HOST_IS_DONE} ]; then
    log info "prepare_host.sh for Cloudera already done"
    unlock "cloudera_prepare_host"
    return 0
fi

# Enabling NTP
# Cf http://www.cloudera.com/documentation/enterprise/latest/topics/install_cdh_enable_ntp.html

if [[ -z "${NTP_SERVER}" ]] || [[ "${NTP_SERVER}" == "DEFAULT" ]] || [[ "${NTP_SERVER}" == "null" ]]; then
    NTP_SERVER=${NTP_DEFAULT_SERVER}
fi

log info "Enable NTP (server=${NTP_SERVER})"
bash ${utils_scripts}/install-components.sh "ntp ntpdate"
sudo systemctl enable ntpd.service
sudo sed -i 's/^server/#server/g' /etc/ntp.conf
sudo bash -c "echo server $NTP_SERVER >>/etc/ntp.conf"
sudo systemctl start ntpd.service
sudo ntpdate -u ${NTP_SERVER}
sudo hwclock --systohc
sudo systemctl restart ntpd.service

# Disable firewall
# Cf http://www.cloudera.com/documentation/enterprise/latest/topics/install_cdh_disable_iptables.html
log info "Disable firewall"
sudo systemctl disable firewalld || true
sudo systemctl stop firewalld || true

# Disable SELinux
# Cf http://www.cloudera.com/documentation/enterprise/latest/topics/install_cdh_disable_selinux.html
log info "Disable SELinux"
if [[ "$(getenforce)" = "Enforcing" ]]
then
	sudo bash <<EOF
    sed -i -e 's/^SELINUX=.*/SELINUX=permissive/' /etc/sysconfig/selinux
    setenforce 0
EOF
fi

# Resolve hostname
# http://www.cloudera.com/documentation/enterprise/latest/topics/cdh_ig_networknames_configure.html
log info "Change /etc/hosts"
sudo bash <<EOF
cp /etc/hosts /etc/hosts.initial
sed -i -s "/127.0.0.1.*$(hostname)/s/^/###/" /etc/hosts
EOF

# Optimizing Performance for CDH
# Cf http://www.cloudera.com/documentation/enterprise/latest/topics/cdh_admin_performance.html
log info "Optimize Performance for CDH"
sudo bash <<EOF
echo never > /sys/kernel/mm/transparent_hugepage/defrag
echo "echo never > /sys/kernel/mm/transparent_hugepage/defrag" >>/etc/rc.local

echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >>/etc/rc.local

echo "1" > /proc/sys/vm/swappiness
EOF

# prepare_host.sh for Cloudera done
touch ${PREPARE_HOST_IS_DONE}
unlock "cloudera_prepare_host"
