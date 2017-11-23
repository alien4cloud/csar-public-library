#!/bin/bash

sudo -s # we need to pass root user to launch puppet recipe

# delete directory puppet and config directory puppet 
PUPPET_DIR=/etc/puppet
if [ -d "$PUPPET_DIR" ]
then
	sudo rm -r $PUPPET_DIR/*
	sudo mkdir $FACTER_PUPPET_HOME
	sudo mv $puppet_file $FACTER_PUPPET_HOME
	sudo unzip $FACTER_PUPPET_HOME/recipe.puppet -d $FACTER_PUPPET_HOME
    sudo rm $FACTER_PUPPET_HOME/recipe.puppet
	sudo chown -R root:root $FACTER_PUPPET_HOME
else 
	echo "agent puppet not installed."
fi
 
# lauch the recipe

cd $FACTER_PUPPET_HOME/manifests

sudo -E puppet apply create.pp

