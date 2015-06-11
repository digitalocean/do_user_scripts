#!/bin/sh
#
# Wordpress Setup Script
#
# This script will install and configure Wordpress on
# an Ubuntu 15.04 droplet
export DEBIAN_FRONTEND=noninteractive;

# Generate root and wordpress mysql passwords
rootmysqlpass="<%ROOT_MYSQL_PASSWORD%>";
wpmysqlpass="<%WORDPRESS MYSQL PASSWORD%>";

# Update Ubuntu
apt-get update;
apt-get -y upgrade;

# Install Apache/MySQL
apt-get -y install apache2 php5 php5-mysql mysql-server mysql-client unzip;

# Download and uncompress Wordpress
wget https://wordpress.org/latest.zip -O /tmp/wordpress.zip;
cd /tmp/;
unzip /tmp/wordpress.zip;
# Set up database user
/usr/bin/mysqladmin -u root -h localhost create wordpress;
/usr/bin/mysqladmin -u root -h localhost password $rootmysqlpass;
/usr/bin/mysql -uroot -p$rootmysqlpass -e "CREATE USER wordpress@localhost IDENTIFIED BY '"$wpmysqlpass"'";
/usr/bin/mysql -uroot -p$rootmysqlpass -e "GRANT ALL PRIVILEGES ON wordpress.* TO wordpress@localhost";

# Configure Wordpress
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php;
sed -i "s/'DB_NAME', 'database_name_here'/'DB_NAME', 'wordpress'/g" /tmp/wordpress/wp-config.php;
sed -i "s/'DB_USER', 'username_here'/'DB_USER', 'wordpress'/g" /tmp/wordpress/wp-config.php;
sed -i "s/'DB_PASSWORD', 'password_here'/'DB_PASSWORD', '$wpmysqlpass'/g" /tmp/wordpress/wp-config.php;
cp -Rf /tmp/wordpress/* /var/www/html/.;
rm -f /var/www/html/index.html;
chown -Rf www-data:www-data /var/www/html;
a2enmod rewrite;
service apache2 restart;
