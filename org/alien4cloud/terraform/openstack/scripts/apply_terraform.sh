#!/bin/bash -xe

# Debug Terraform
# export TF_LOG=DEBUG
# export OS_DEBUG=1

# Init
WORKING_DIR="/opt/a4c_terraform/$INSTANCE"
# INPUT_FILE=$WORKING_DIR/tf-input
OUTPUT_FILE="$WORKING_DIR/tf-output"
REL_INPUT_FILE="$WORKING_DIR/tf-rel-inputs"
OUTPUT_ENV_FILE="$WORKING_DIR/env-output"

cd "$WORKING_DIR"

if [ -f $REL_INPUT_FILE ] ; then 
  ADDITIONAL_VAR_FILE_OPTS="-var-file $REL_INPUT_FILE"
fi

# Execute
terraform init
terraform apply -var-file $INPUT_FILE $ADDITIONAL_VAR_FILE_OPTS
terraform output > $OUTPUT_FILE

# Retrieve outputs
cp $OUTPUT_FILE $OUTPUT_ENV_FILE
sed -i 's#\(.*\) = \(.*\)#export \1="\2"#' $OUTPUT_ENV_FILE
# export TERRAFORM_OUTPUT=$(cat $OUTPUT_FILE) 
source $OUTPUT_ENV_FILE # To get expected attributes for a4c

# EXPECTED_OUTPUT_PUBLIC_IP_ADDRESS=
# EXPECTED_OUTPUT_IP_ADDRESS=
# EXPECTED_OUTPUT_INSTANCE_ID=
