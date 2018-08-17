#!/bin/bash -e

if [ ! -f "$safe_clean_patch" ] ; then
  echo "script not found"
  exit 0
fi

sudo chmod +x $safe_clean_patch
sudo $safe_clean_patch