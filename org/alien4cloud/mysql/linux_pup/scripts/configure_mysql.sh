#!/bin/bash

sudo -s
# start mysql

cd $FACTER_PUPPET_HOME/manifests

sudo -E puppet apply configure.pp