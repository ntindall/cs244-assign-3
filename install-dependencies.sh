#!/usr/bin/env bash

#AMI- ubuntu-trusty-14.04-amd64-server-20150325 (ami-5189a661)

# Exit on any failure
set -e

# Check for uninitialized variables
set -o

# install dependencies
sudo apt-get update
sudo apt-get install automake autopoint git make pkg-config libtool flex nginx wget libpcre3-dev python-numpy --yes
sudo update-rc.d nginx disable
sudo service nginx stop
