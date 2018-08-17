#!/bin/bash -x


# #################################
# ######## KUBE MASTER     ########
# #################################

# Some users on RHEL/CentOS 7 have reported issues with traffic being routed incorrectly due to iptables being bypassed. You should ensure net.bridge.bridge-nf-call-iptables is set to 1 in your sysctl config, e.g.
# <Optional>
# $  cat <<EOF >  /etc/sysctl.d/k8s.conf
# $>  net.bridge.bridge-nf-call-ip6tables = 1
# $>  net.bridge.bridge-nf-call-iptables = 1
# $> EOF
# $  sysctl --system
# </Optional>

# https://github.com/kubernetes/kubernetes/issues/40969
sudo kubeadm init --skip-preflight-checks --pod-network-cidr 10.244.0.0/16

# If issues, check logs 
# systemctl status kubelet
# journalctl -xeu kubelet
#c.f. Troubleshooting 

# Flannel: For flannel to work correctly, --pod-network-cidr=10.244.0.0/16 has to be passed to kubeadm init.
sudo kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.0/Documentation/kube-flannel.yml

# Master Isolation - Optional (not recommanded)
# By default, your cluster will not schedule pods on the master for security reasons.
# If you want to be able to schedule pods on the master, e.g. for a single-machine Kubernetes cluster for development,
# run:
# sudo kubectl taint nodes --all node-role.kubernetes.io/master-


# #################################
# ######## KUBE DASHBOARD  ########
# #################################

# Deploy Kubernetes Dashboard
sudo kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml

# Deploy Kubernetes Dashboard NodePort Service
sudo kubectl --kubeconfig /etc/kubernetes/admin.conf -n kube-system delete service kubernetes-dashboard
cat <<EOF | sudo kubectl --kubeconfig /etc/kubernetes/admin.conf create -f -
kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kube-system
spec:
  type: NodePort
  ports:
    - port: 443
      targetPort: 8443
      nodePort: 30000
  selector:
    k8s-app: kubernetes-dashboard
EOF

# Granting admin privileges to Dashboard's Service Account 
cat <<EOF | sudo kubectl --kubeconfig /etc/kubernetes/admin.conf create -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard
  labels:
    k8s-app: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: kubernetes-dashboard
  namespace: kube-system
EOF
# Afterwards you can use Skip option on login page to access Dashboard

# Access dashboard from external:
# - https://github.com/kubernetes/dashboard/wiki/Access-control
# - https://github.com/kubernetes/dashboard/issues/2034
# - https://stackoverflow.com/questions/46664104/how-to-sign-in-kubernetes-dashboard


# #################################
# ####### EXPORT VARIABLES ########
# #################################

# Export variables to join cluster.
# TODO not secured, should change a way to retrieve those informations.

export KUBE_TOKEN=$(sudo kubeadm token list | grep "The default bootstrap token generated" | cut -d ' ' -f1)
export KUBE_SHA256=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')