#!/bin/sh
#
# Bolt CMS Setup Script
#
# This script will install and configure Bolt CMS on
# an Ubuntu 16.04 droplet
export DEBIAN_FRONTEND=noninteractive;

# Generate root and Bolt mysql passwords
rootmysqlpass=`dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev | tr -dc 'a-zA-Z0-9'`;
wpmysqlpass=`dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev | tr -dc 'a-zA-Z0-9'`;

# Write passwords to file
echo "Root MySQL Password: $rootmysqlpass" > /root/passwords.txt;
echo "Bolt MySQL Password: $wpmysqlpass" >> /root/passwords.txt;

# Update Ubuntu
apt-get update;
apt-get -y upgrade;

# Install Apache/MySQL
apt-get -y install apache2 php php-mysql libapache2-mod-php7.0 php7.0-mysql php7.0-curl php7.0-zip php7.0-json php7.0-xml php7.0-mbstring php7.0-gd mysql-server mysql-client unzip tar curl;

# Download and uncompress Bolt
cd /var/www/;
curl -O https://bolt.cm/distribution/bolt-latest.tar.gz;
tar -xzf bolt-latest.tar.gz --strip-components=1;
php app/nut setup:sync;

# Set up database user
/usr/bin/mysqladmin -u root -h localhost create bolt;
/usr/bin/mysqladmin -u root -h localhost password $rootmysqlpass;
/usr/bin/mysql -uroot -p$rootmysqlpass -e "CREATE USER bolt@localhost IDENTIFIED BY '"$wpmysqlpass"'";
/usr/bin/mysql -uroot -p$rootmysqlpass -e "GRANT ALL PRIVILEGES ON bolt.* TO bolt@localhost";

# Configure Apache
sed -i "/DocumentRoot \/var\/www\/html/ a\
\        FallbackResource /index.php" /etc/apache2/sites-available/000-default.conf;

# Configure Bolt
sed -i "s/driver: sqlite/driver: mysql/g" /var/www/app/config/config.yml;
sed -i "/databasename: bolt/ a\
\    username: bolt" /var/www/app/config/config.yml;
sed -i "/username: bolt/ a\
\    password: $wpmysqlpass" /var/www/app/config/config.yml;
sed -i "s/: public/: html/g" /var/www/.bolt.yml;

# Relocate missing files
shopt -s dotglob nullglob;
rm -rf /var/www/html;
mv /var/www/public /var/www/html;
chown -Rf www-data:www-data /var/www;
chmod -Rf 777 html/files/ html/theme/ html/thumbs/;
chmod -Rf 777 app/database/ app/cache/ app/config/ extensions/;
a2enmod rewrite;
service apache2 restart;
