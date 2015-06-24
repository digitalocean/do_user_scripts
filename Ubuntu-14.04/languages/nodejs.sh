#!/bin/bash
export DEBIAN_FRONTEND=noninteractive;
apt-get update;
VERSION=`curl -s http://nodejs.org/dist/latest/SHASUMS.txt | awk '/node-v/ {print $2}' | head -1 | sed s/node-v// | sed s/-/\ / | awk '{print $1}'`
url="http://nodejs.org/dist/v"$VERSION"/node-v"$VERSION".tar.gz"
curl $url | tar -zxf -
cd "node-v"$VERSION
# Doing Deps
# For some reason everything after apt-get requires explicit &&
apt-get -y install build-essential openssl libssl-dev pkg-config && 
# Time to Install
./configure &&
make &&
make install &&
cd .. &&
rm -rf node-v$VERSION &&
node --version &&
exit
