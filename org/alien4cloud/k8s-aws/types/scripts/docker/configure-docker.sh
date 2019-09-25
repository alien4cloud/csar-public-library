#!/bin/bash -x

sudo systemctl enable docker
sudo groupadd docker
sudo usermod -aG docker $(whoami)