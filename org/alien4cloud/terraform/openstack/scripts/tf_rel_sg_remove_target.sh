#!/bin/bash -xe

WORKING_DIR="/opt/a4c_terraform/rel-${SOURCE_INSTANCE}-${TARGET_INSTANCE}"

INPUT_FILE=$WORKING_DIR/tf-input

cd "$WORKING_DIR"

# Execute
terraform destroy -force -var-file $INPUT_FILE

# Clean
if [ -d "$WORKING_DIR" ] ; then
  sudo rm -fr "$WORKING_DIR"
fi