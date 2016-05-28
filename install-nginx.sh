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

rm -f nginx-1.9.0.tar.gz
rm -rf nginx-1.9.0
wget http://nginx.org/download/nginx-1.9.0.tar.gz
tar xf nginx-1.9.0.tar.gz
cd nginx-1.9.0
./configure --without-http_gzip_module
make -j3
sudo mkdir -p /usr/local/nginx/logs/

cd $dir