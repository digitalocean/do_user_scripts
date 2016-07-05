#!/bin/sh
#
# MediaWiki Setup Script
#
# This script will install and configure MediaWiki on
# an Ubuntu 14.04 droplet
export DEBIAN_FRONTEND=noninteractive;

# Generate root and wordpress mysql passwords
rootmysqlpass=`dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev | tr -dc 'a-zA-Z0-9'`;
mwmysqlpass=`dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev | tr -dc 'a-zA-Z0-9'`;


# Write passwords to file
echo "MySQL Passwords for this droplet " > /etc/motd.tail;
echo "-----------------------------------" >> /etc/motd.tail;
echo "Root MySQL Password: $rootmysqlpass" >> /etc/motd.tail;
echo "MediaWiki MySQL Database: mwdb" >> /etc/motd.tail;
echo "Mediawiki MySQL Username: mwsql" >> /etc/motd.tail;
echo "Mediawiki MySQL Password: $mwmysqlpass" >> /etc/motd.tail;
echo "-----------------------------------" >> /etc/motd.tail;
echo "You can remove this information with 'rm -f /etc/motd.tail'" >> /etc/motd.tail;

apt-get update;
apt-get -y install apache2 mysql-server libapache2-mod-auth-mysql php5-mysql php5 libapache2-mod-php5 php5-mcrypt php5-gd php5-intl php-pear php5-dev make libpcre3-dev php-apc;

# Set up database user
/usr/bin/mysqladmin -u root -h localhost create mwdb;
/usr/bin/mysqladmin -u root -h localhost password $rootmysqlpass;
/usr/bin/mysql -uroot -p$rootmysqlpass -e "CREATE USER mwsql@localhost IDENTIFIED BY '"$mwmysqlpass"'";
/usr/bin/mysql -uroot -p$rootmysqlpass -e "GRANT ALL PRIVILEGES ON mwdb.* TO mwsql@localhost";


rm -f /var/www/html/index.html;
wget http://releases.wikimedia.org/mediawiki/1.25/mediawiki-1.25.1.tar.gz -O /root/mediawiki.tar.gz;
cd /root;
tar -zxf /root/mediawiki.tar.gz;
cp -Rf /root/mediawiki-1.25.1/* /var/www/html/.;
#rm /root/mediawiki.tar.gz;
#rm -Rf /root/mediawiki-1.25.1;
chown -Rf www-data.www-data /var/www/html;
service apache2 restart;

cat /etc/motd.tail > /var/run/motd.dynamic;
chmod 0660 /var/run/motd.dynamic;
