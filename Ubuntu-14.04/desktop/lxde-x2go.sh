#!/bin/sh
#
# This script will set up an lxde desktop environment which can be
# accessed remotely via the x2goclient http://wiki.x2go.org/doku.php/doc:installation:x2goclient
# This script also creates a shortcut for the "startlxde" command used by the default
# x2go lxde session configuration.
export DEBIAN_FRONTEND=noninteractive;
apt-get update;
apt-get -y install software-properties-common lubuntu-desktop;
add-apt-repository -y ppa:x2go/stable;
apt-get update;
apt-get -y install x2goserver x2goserver-xsession;
echo "#!/bin/sh" > /usr/bin/startlxde;
echo "/usr/bin/lxsession -s Lubuntu -e LXDE" >> /usr/bin/startlxde;
chmod +x /usr/bin/startlxde;