#!/bin/bash
set -e

echo "Starting identidock system"

docker run -d --restart=always --name redis redis

docker run -d --restart=always --name dnmonster amouat/dnmonster

docker run -d --restart=always --name identidock --link dnmonster:dnmonster --link redis:redis \
    -e ENV=PROD identidock

docker run -d --restart=always --name proxy --link identidock:identidock -p 80:80 \
    -e NGINX_HOST=45.55.251.164 -e NGINX_PROXY=http://identidock:9090 \
    amouat/proxy:1.0

echo "Started"