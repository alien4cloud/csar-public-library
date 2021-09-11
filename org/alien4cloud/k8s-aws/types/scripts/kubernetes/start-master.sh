#!/bin/bash -x

# Set IAM Role
aws ec2 associate-iam-instance-profile --instance-id $AWS_ID --iam-instance-profile Name=$IAM_ROLE

# Create configuration
sudo mkdir -p /etc/kubernetes

cat <<EOF | envsubst | sudo tee /etc/kubernetes/aws.yml
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
nodeRegistration:
  name: ${HOSTNAME}
  kubeletExtraArgs:
    cloud-provider: "aws"
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
networking:
  serviceSubnet: "10.100.0.0/16"
  podSubnet: "10.244.0.0/16"
apiServer:
  extraArgs:
    cloud-provider: "aws"
controllerManager:
  extraArgs:
    cloud-provider: "aws"
    configure-cloud-routes: "false"
EOF

# Init master
sudo kubeadm init --config /etc/kubernetes/aws.yml

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Flannel: For flannel to work correctly, --pod-network-cidr=10.244.0.0/16 has to be passed to kubeadm init.
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
#kubectl apply -f https://raw.githubusercontent.com/mgoltzsche/flannel/add-cni-version/Documentation/kube-flannel.yml
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml 

# Master Isolation - Optional (not recommanded)
# By default, your cluster will not schedule pods on the master for security reasons.
# If you want to be able to schedule pods on the master, e.g. for a single-machine Kubernetes cluster for development,
# run:
# sudo kubectl taint nodes --all node-role.kubernetes.io/master-

# #################################
# ######## KUBE DASHBOARD  ########
# #################################

# Deploy Kubernetes Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

# Deploy Kubernetes Dashboard NodePort Service
kubectl -n kube-system delete service kubernetes-dashboard
cat <<EOF | kubectl create -f -
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
cat <<EOF | kubectl create -f -
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

export KUBE_TOKEN=$(sudo kubeadm token list | grep "default-node-token" | cut -d ' ' -f1)
export KUBE_SHA256=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')