#!/usr/bin/env bash


source ${utils_scripts}/utils.sh

log begin
sudo rstudio-server stop
log end "RStudio stopped !"