#!/bin/bash -x

# Installe prerequisite packages
sudo yum -y install ebtables ethtool

# #################################
# ######## KUBE CLUSTER    ########
# #################################

# Install kubernetes repository
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

sudo bash -c "echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables"

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

sudo systemctl enable --now kubelet

AWS_ID=$(aws ec2 describe-instances --query "Reservations[*].Instances[?(NetworkInterfaces[0].PrivateIpAddress=='$AWS_IP')].InstanceId" --output text)

aws ec2 create-tags --resource $AWS_ID --tags Key=kubernetes.io/cluster/$CLUSTER_NAME,Value=