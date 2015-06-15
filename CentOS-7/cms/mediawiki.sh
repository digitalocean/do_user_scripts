#!/bin/sh
#
# MediaWiki Setup Script
#
# This script will install and configure MediaWiki on
# a CentOS 7 droplet

# Generate root and wordpress mysql passwords
rootmysqlpass=`dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev`
mwmysqlpass=`dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev`

# Write passwords to file
echo "MySQL Passwords for this droplet " > /etc/motd;
echo "-----------------------------------" >> /etc/motd;
echo "Root MySQL Password: $rootmysqlpass" >> /etc/motd;
echo "MediaWiki MySQL Database: mwdb" >> /etc/motd;
echo "Mediawiki MySQL Username: mwsql" >> /etc/motd;
echo "Mediawiki MySQL Password: $mwmysqlpass" >> /etc/motd;
echo "-----------------------------------" >> /etc/motd;
echo "You can remove this information with 'cat /dev/null > /etc/motd'" >> /etc/motd;

yum -y install httpd mariadb-server mariadb php-mysql php php-mcrypt php-gd php-xml;
systemctl start mariadb;
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
rm /root/mediawiki.tar.gz;
rm -Rf /root/mediawiki-1.25.1;
chown -Rf apache.apache /var/www/html;
systemctl start httpd;

cat /etc/motd.tail > /var/run/motd.dynamic;
chmod 0660 /var/run/motd.dynamic;
