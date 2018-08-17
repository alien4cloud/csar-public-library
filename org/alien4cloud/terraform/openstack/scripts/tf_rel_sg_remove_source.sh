#!/bin/bash -xe


TARGET_WORKING_DIR="/opt/a4c_terraform/${TARGET_INSTANCE}"

rm -fr "${TARGET_WORKING_DIR}/tf-rel-${SOURCE_INSTANCE}-${TARGET_INSTANCE}-inputs"
rm -fr "$TARGET_WORKING_DIR/rel_port_${SOURCE_INSTANCE}_${TARGET_INSTANCE}_override.tf"

cd $TARGET_WORKING_DIR
terraform apply -var-file tf-input
