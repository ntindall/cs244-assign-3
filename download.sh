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

rm -rf scratch
mkdir scratch
cd scratch

function pageDownloadInitial(){
    rm -rf $1
    mkdir $1
    cd $1
    wget -Hp --user-agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.0 Safari/537.36" -erobots=off $2
    for i in `find . -type f`; do gzip -9 <$i >/tmp/tmp; y=`stat -c %s /tmp/tmp`; openssl rand $y -out $i; done
    cd ..
}

pageDownloadInitial amazon http://www.amazon.com
pageDownloadInitial nytimes http://www.nytimes.com
pageDownloadInitial wsj http://www.wsj.com
pageDownloadInitial wikipedia http://en.wikipedia.org/wiki/Transmission_Control_Protocol

cd $dir