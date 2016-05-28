#!/usr/bin/env bash

dir=`pwd`
# Exit on any failure
set -e

# Check for uninitialized variables
set -o nounset

ctrlc() {
    cd $dir
    exit
}
trap ctrlc SIGINT

cd ~

cat << EOF >.nginxrc
worker_processes 4;
pid /run/nginx.pid;

events {
  worker_connections 768;
}

http {
  keepalive_requests 2;
  types_hash_max_size 2048;

  include /etc/nginx/mime.types;
  default_type application/octet-stream;

  server {
	listen 8000 fastopen=9999 backlog=9999;
	server_name "test";
	access_log off;
	error_log /dev/null;

	location /{
	  root $HOME/scratch;
	}
  }
}
EOF

cd $dir
