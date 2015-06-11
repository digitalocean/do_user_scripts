#!/bin/sh
#
# Wordpress Setup Script
#
# This script will install and configure Wordpress on
# an CentOS 7 droplet

# Generate root and wordpress mysql passwords
rootmysqlpass=`dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev`
wpmysqlpass=`dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev`

# Write passwords to file
echo "Root MySQL Password: $rootmysqlpass" > /root/passwords.txt;
echo "Wordpress MySQL Password: $wpmysqlpass" >> /root/passwords.txt;


# Update CentOS
yum -y update;

# Install Apache/MySQL
yum -y install httpd php php-mysql mariadb-server mariadb unzip;

# Start services
systemctl start mariadb;
systemctl start httpd;

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
chown -Rf apache:apache /var/www/html;
systemctl enable httpd.service;
systemctl enable mariadb.service;
systemctl restart httpd.service;
