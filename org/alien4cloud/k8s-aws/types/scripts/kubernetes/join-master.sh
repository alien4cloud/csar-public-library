#!/bin/bash -x

env

# Expected env var
if [ -z "$PRIVATE_ADDRESS" ] ; then
  echo "Missing env variable PRIVATE_ADDRESS"
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

sudo mkdir -p /etc/kubernetes

cat <<EOF | envsubst | sudo tee /etc/kubernetes/aws.yml
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: JoinConfiguration
discovery:
  bootstrapToken:
    token: "${KUBE_TOKEN}"
    apiServerEndpoint: "${PRIVATE_ADDRESS}:6443"
    caCertHashes:
      - "sha256:${KUBE_SHA256}"
nodeRegistration:
  name: ${HOSTNAME}
  kubeletExtraArgs:
    cloud-provider: aws
EOF

sudo kubeadm join --config /etc/kubernetes/aws.yml



