#!/bin/bash

cd /home/ubuntu
#install agent puppet 
wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
sudo dpkg -i puppetlabs-release-trusty.deb
sudo apt-get update
sudo apt-get install puppet
sudo apt-get install puppet-common -y
sudo apt-get install unzip -y


