#!/bin/bash -xe

WORKING_DIR="/opt/a4c_terraform/$INSTANCE"

# IF $FLOATING_IPS has values, override the compute default tf file
if [ ! -z "$FLOATING_IPS" ] ; then
  rm -f $WORKING_DIR/$(basename "$ARTIFACT_TERRAFORM")
  cp $ARTIFACT_TERRAFORM_EXISTING_FIP $WORKING_DIR
fi