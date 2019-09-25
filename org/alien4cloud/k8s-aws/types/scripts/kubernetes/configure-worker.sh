#!/bin/bash -x

env 

# Set IAM Role
aws ec2 associate-iam-instance-profile --instance-id $AWS_ID --iam-instance-profile Name=$IAM_ROLE