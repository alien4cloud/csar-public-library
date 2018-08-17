#!/bin/bash -x

sudo systemctl enable docker
sudo usermod -a -G docker $(whoami)