#!/usr/bin/env bash

dir=`pwd`

# Check for uninitialized variables
set -o nounset

ctrlc() {
	cd $dir
	exit
}
trap ctrlc SIGINT

cd ~
rm -rf mget
git clone https://github.com/rockdaboot/mget.git
touch ~/.mgetrc
cd mget
git checkout f878d8c907f02679a0d3e9bf8065b0c362a92d2d
./autogen.sh
./configure
make -j3
cd $dir
