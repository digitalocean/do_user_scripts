#!/bin/sh
#
# Wordpress Setup Script
#
# This script will install and configure WordPress on an Ubuntu 16.04 droplet
export DEBIAN_FRONTEND=noninteractive;

# Generate root mysql password
rootmysqlpass=`dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev | tr -dc 'a-zA-Z0-9'`;

# wp mysql pass
wpmysqlpass=`dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev | tr -dc 'a-zA-Z0-9'`;

# wp mysql user
wpmysqlusertable=`dd if=/dev/urandom | tr -dc 'a-z' | fold -w 12 | head -n 1`;

# wp site url
wpsiteurl=http://`curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address`;

# wp site title
wpsitetitle=Wordpress;

# wp table preix
wptableprefix=`dd if=/dev/urandom | tr -dc 'a-z' | fold -w 4 | head -n 1`_wp_;

# wp admin login
wpadminlogin=`dd if=/dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1`;

# wp admin password
wpadminpass=`dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev | tr -dc 'a-zA-Z0-9'`;

# wp admin email
wpadminemail=ENTER-HERE-YOUR-WP-ADMIN-EMAIL;

# Write passwords to file
echo "Root MySQL Password: $rootmysqlpass" > /root/passwords.txt;
echo "Wordpress MySQL Password: $wpmysqlpass" >> /root/passwords.txt;
echo "Wordpress MySQL User and Table Name: $wpmysqlusertable" >> /root/passwords.txt;
echo "Wordpress Admin Login: $wpadminlogin" >> /root/passwords.txt;
echo "Wordpress Admin Password: $wpadminpass" >> /root/passwords.txt;

# Update Ubuntu
apt-get update;
apt-get -y upgrade;

# Install Apache/MySQL
apt-get -y install apache2 php php-mysql libapache2-mod-php7.0 php7.0-mysql php7.0-curl php7.0-zip php7.0-json php7.0-xml mysql-server mysql-client unzip wget;

# Download and uncompress WordPress
wget https://wordpress.org/latest.zip -O /tmp/wordpress.zip;
cd /tmp/;
unzip /tmp/wordpress.zip;

# Set up database user
/usr/bin/mysqladmin -u root -h localhost create $wpmysqlusertable;
/usr/bin/mysqladmin -u root -h localhost password $rootmysqlpass;
/usr/bin/mysql -uroot -p$rootmysqlpass -e "CREATE USER $wpmysqlusertable@localhost IDENTIFIED BY '"$wpmysqlpass"'";
/usr/bin/mysql -uroot -p$rootmysqlpass -e "GRANT ALL PRIVILEGES ON $wpmysqlusertable.* TO $wpmysqlusertable@localhost";

# Configure WordPress
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php;
sed -i "s/'DB_NAME', 'database_name_here'/'DB_NAME', '$wpmysqlusertable'/g" /tmp/wordpress/wp-config.php;
sed -i "s/'DB_USER', 'username_here'/'DB_USER', '$wpmysqlusertable'/g" /tmp/wordpress/wp-config.php;
sed -i "s/'DB_PASSWORD', 'password_here'/'DB_PASSWORD', '$wpmysqlpass'/g" /tmp/wordpress/wp-config.php;

for i in `seq 1 8`
do
wp_salt=$(</dev/urandom tr -dc 'a-zA-Z0-9!@#$%^&*()\-_ []{}<>~`+=,.;:/?|' | head -c 64 | sed -e 's/[\/&]/\\&/g');
sed -i "0,/put your unique phrase here/s/put your unique phrase here/$wp_salt/" /tmp/wordpress/wp-config.php;
done

sed -i "s/$table_prefix  = 'wp_'/$table_prefix  = '$wptableprefix'/g" /tmp/wordpress/wp-config.php;

cp -Rf /tmp/wordpress/* /var/www/html/.;
rm -f /var/www/html/index.html;
rm -f /var/www/html/wp-config-sample.php;
chown -Rf www-data:www-data /var/www/html;

# install wp-cli
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /tmp/wp-cli.phar;
cd /tmp/;
chmod +x wp-cli.phar;
mv wp-cli.phar /usr/local/bin/wp;

# install wp
/usr/local/bin/wp core install  --allow-root --path=/var/www/html/ --url=$wpsiteurl --title=$wpsitetitle --admin_user=$wpadminlogin --admin_password=$wpadminpass --admin_email=$wpadminemail;

a2enmod rewrite;
service apache2 restart;
