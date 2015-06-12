#!/bin/sh
#
# This script will set up an xfce desktop environment which can be
# accessed remotely via the x2goclient http://wiki.x2go.org/doku.php/doc:installation:x2goclient
export DEBIAN_FRONTEND=noninteractive;
apt-get update;
apt-get -y install software-properties-common kubuntu-desktop;
add-apt-repository -y ppa:x2go/stable;
apt-get update;
apt-get -y install x2goserver x2goserver-xsession;