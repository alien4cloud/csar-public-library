#!/bin/bash

sudo -s # we need to pass root user to launch puppet recipe

# delete directory puppet and config directory puppet 

if [ -d "$PUPPET_HOME" ]
then
	sudo rm -r $PUPPET_HOME/*
	sudo mv $puppet_file $PUPPET_HOME
	sudo unzip $PUPPET_HOME/recipe.puppet -d $PUPPET_HOME
    sudo rm $PUPPET_HOME/recipe.puppet
	sudo chown -R root:root $PUPPET_HOME
else 
	echo "agent puppet not installed."
fi
 
# lauch the recipe

cd $PUPPET_HOME/manifests

sudo -E puppet apply create.pp

