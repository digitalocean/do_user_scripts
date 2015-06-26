#!/bin/bash
dnf -y group install "Development Tools";
dnf -y install python curl openssl openssl-devel pkgconfig gcc-c++;

VERSION=`curl -s http://nodejs.org/dist/latest/SHASUMS.txt | awk '/node-v/ {print $2}' | head -1 | sed s/node-v// | sed s/-/\ / | awk '{print $1}'`
url="http://nodejs.org/dist/v"$VERSION"/node-v"$VERSION".tar.gz"
curl $url | tar -zxf -
cd "node-v"$VERSION

# Time to Install
./configure &&
make &&
make install &&
cd .. &&
rm -rf node-v$VERSION &&
node --version &&
exit