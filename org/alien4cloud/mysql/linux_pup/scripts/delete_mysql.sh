#!/bin/bash
sudo -s
cd $FACTER_PUPPET_HOME/manifests

sudo -E puppet apply delete.pp