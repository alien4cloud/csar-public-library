#!/bin/bash -xe

#
# Retrieve all secgroup ids and attach it to the compute ports
#

SOURCE_WORKING_DIR="/opt/a4c_terraform/${SOURCE_INSTANCE}"
TARGET_WORKING_DIR="/opt/a4c_terraform/${TARGET_INSTANCE}"

TARGET_ENV_REL_INPUT_FILE="${TARGET_WORKING_DIR}/tf-rel-${SOURCE_INSTANCE}-${TARGET_INSTANCE}-inputs"
SOURCE_OUTPUT_FILE="${SOURCE_WORKING_DIR}/tf-output"
# TARGET_OUTPUT_FILE="${TARGET_WORKING_DIR}/tf-output"
# TARGET_OUTPUT_ENV_FILE="${TARGET_WORKING_DIR}/env-output"

# Get newly created secgroup id from terraform output
INT_SECGROUP_ID=$(grep _TF_SG_a4c_internal ${SOURCE_OUTPUT_FILE} | sed 's/.* = \(.*\)/\1/')
EXT_SECGROUP_ID=$(grep _TF_SG_a4c_external ${SOURCE_OUTPUT_FILE} | sed 's/.* = \(.*\)/\1/')

# Save it into an inputs file
echo "NEW_INT_SECGROUP_IDS = [ \"${INT_SECGROUP_ID}\" ]" >> $TARGET_ENV_REL_INPUT_FILE
echo "NEW_EXT_SECGROUP_IDS = [ \"${EXT_SECGROUP_ID}\" ]" >> $TARGET_ENV_REL_INPUT_FILE

# Copy override artifact into 
cp $ARTIFACT_PORT_OVERRIDE $TARGET_WORKING_DIR/rel_port_${SOURCE_INSTANCE}_${TARGET_INSTANCE}_override.tf

# Apply changes
cd $TARGET_WORKING_DIR
terraform plan -var-file tf-input -var-file $TARGET_ENV_REL_INPUT_FILE
terraform apply -var-file tf-input -var-file $TARGET_ENV_REL_INPUT_FILE
# terraform output > $TARGET_OUTPUT_FILE

# # Retrieve outputs
# cp $TARGET_OUTPUT_FILE $TARGET_OUTPUT_ENV_FILE
# sed -i 's#\(.*\) = \(.*\)#export \1="\2"#' $TARGET_OUTPUT_ENV_FILE
# source $TARGET_OUTPUT_ENV_FILE # To get expected attributes for a4c