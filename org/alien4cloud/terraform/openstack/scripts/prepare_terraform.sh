#!/bin/bash -xe

# Variables
WORKING_DIR="/opt/a4c_terraform/$INSTANCE"
INPUT_FILE=$WORKING_DIR/tf-input
OUTPUT_FILE=$WORKING_DIR/tf-output

# Init
if [ -d "$WORKING_DIR" ] ; then
  sudo rm -fr "$WORKING_DIR"
fi
sudo mkdir -p "$WORKING_DIR"
sudo chown -R $(whoami) "$WORKING_DIR"

cp $ARTIFACT_TERRAFORM $WORKING_DIR
cd "$WORKING_DIR"

# Generation inputs file
python $ARTIFACT_PYTHON -o $INPUT_FILE

export INPUT_FILE="$INPUT_FILE"