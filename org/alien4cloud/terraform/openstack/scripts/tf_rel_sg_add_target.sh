#!/bin/bash -xe

WORKING_DIR="/opt/a4c_terraform/rel-${SOURCE_INSTANCE}-${TARGET_INSTANCE}"

INPUT_FILE=$WORKING_DIR/tf-input

# Init
if [ -d "$WORKING_DIR" ] ; then
  sudo rm -fr "$WORKING_DIR"
fi
sudo mkdir -p "$WORKING_DIR"
sudo chown -R $(whoami) "$WORKING_DIR"

cp $ARTIFACT_REL_SG_TERRAFORM $WORKING_DIR
cd "$WORKING_DIR"

# Generation inputs file
python $ARTIFACT_PYTHON -o $INPUT_FILE

# Retrieve the floating ip from the Compute's output file
# TARGET_WORKING_DIR="/opt/a4c_terraform/$TARGET_INSTANCE"
# TARGET_OUTPUT_FILE="$TARGET_WORKING_DIR/tf-output"
# FLOATING_IP=$(grep PUBLIC_IP_ADDRESS $TARGET_OUTPUT_FILE | sed 's/.* = \(.*\)/\1/')
# echo "FLOATING_IP = \"$FLOATING_IP\"" >> $INPUT_FILE

# Execute
terraform init
terraform apply -var-file $INPUT_FILE
