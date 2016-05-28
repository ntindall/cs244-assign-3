#!/usr/bin/env bash

dir=`pwd`

# Check for uninitialized variables
set -o nounset

ctrlc() {
    cd $dir
    exit
}
trap ctrlc SIGINT

sudo killall -TERM nginx
sleep 2
sudo killall -KILL nginx

sudo ~/nginx-1.9.0/objs/nginx -c ~/.nginxrc

cd $dir