#!/bin/bash -ex

# Install aws cli
sudo yum install -y python3-pip

# Install AWS CLI
pip3 install awscli --upgrade --user

# Init aws credentials
if [ ! -d ~/.aws ]  ; then
  mkdir ~/.aws
fi

if [ ! -f ~/.aws/config ] ; then
  cat << EOF | envsubst >> ~/.aws/config
[default]
region=${AWS_REGION}
aws_access_key_id=${AWS_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
EOF
fi
