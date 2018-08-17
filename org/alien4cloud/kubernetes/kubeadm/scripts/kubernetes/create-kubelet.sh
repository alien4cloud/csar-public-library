#!/bin/bash -x

# Init
sudo yum -y install ebtables ethtool


# #################################
# ######## KUBE CLUSTER    ########
# #################################

# Installing kubeadm, kubelet and kubectl
cat <<EOF > /tmp/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
cat /tmp/kubernetes.repo | sudo tee -a /etc/yum.repos.d/kubernetes.repo
sudo setenforce 0

sudo yum install -y kubelet kubeadm kubectl

sudo systemctl enable kubelet
sudo systemctl start kubelet


# #################################
# ######## TROUBLESHOOTING ########
# #################################

# Disable swap
echo 'Environment="KUBELET_EXTRA_ARGS=--fail-swap-on=false"' | sudo tee -a /etc/systemd/system/kubelet.service.d/90-local-extras.conf

# Removing swap permanently
# https://www.centos.org/docs/5/html/Deployment_Guide-en-US/s1-swap-removing.html
# https://serverfault.com/questions/684771/best-way-to-disable-swap-in-linux
sudo swapoff -a
# remote any swap entry from /etc/fstab
sudo sed -e '/swap/ s/^#*/#/' -i /etc/fstab
# Check swaps
sudo cat /proc/swaps

# Compare CGROUP 
# docker info |grep -i cgroup
# cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
TMP_CGROUP=$(sudo docker info |grep -i cgroup | sed 's/.*: \(.*\)/\1/')
sudo sed -i "s/--cgroup-driver=\([^\"]*\)/--cgroup-driver=$TMP_CGROUP/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
unset TMP_CGROUP

# Reload kubelet config
sudo systemctl daemon-reload
sudo systemctl restart kubelet
