#!/bin/bash

sudo -s
# start mysql

cd $PUPPET_HOME/manifests

sudo -E puppet apply configure.pp