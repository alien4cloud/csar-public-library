#!/bin/bash -x

# Expected env var
if [ -z "$MASTER_IP" ] ; then
  echo "Missing env variable MASTER_IP"
  exit 1
fi
if [ -z "$KUBE_TOKEN" ] ; then
  echo "Missing env variable KUBE_TOKEN"
  exit 1
fi
if [ -z "$KUBE_SHA256" ] ; then
  echo "Missing env variable KUBE_SHA256"
  exit 1
fi

# #################################
# ######## KUBE NODE       ########
# #################################

# bridge-nf-call-iptables = 1
echo '1' | sudo tee -a /proc/sys/net/bridge/bridge-nf-call-iptables

# Retrieve the token
# sudo kubeadm token list

# The CA key hash is used to verify the full root CA certificate discovered during token-based bootstrapping. 
# It has the format sha256:<hex_encoded_hash>. By default, the hash value is returned in the kubeadm join command printed at the end of kubeadm init. 
# It is in a standard format (see RFC7469) and can also be calculated by 3rd party tools or provisioning systems. 
# For example, using the OpenSSL CLI: 
# sudo openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'

# KUBE_TOKEN=$(kubeadm token list | grep "The default bootstrap token generated" | cut -d ' ' -f1)
# KUBE_SHA256=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')
sudo kubeadm join --token $KUBE_TOKEN $MASTER_IP:6443  --discovery-token-ca-cert-hash sha256:$KUBE_SHA256 --skip-preflight-checks 
#sudo kubectl --kubeconfig /home/ec2-user/admin.conf get no



