#!/bin/bash -x

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
terraform destroy -force -var-file $INPUT_FILE $ADDITIONAL_VAR_FILE_OPTS

# Clean
WORKING_DIR="/opt/a4c_terraform/$INSTANCE"
if [ -d "$WORKING_DIR" ] ; then
  sudo rm -fr "$WORKING_DIR"
fi