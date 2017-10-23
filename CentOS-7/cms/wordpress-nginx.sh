#!/bin/sh
#
# WordPress Setup Script
#
# This script will install and configure Wordpress on
# an CentOS 7 droplet

# Generate root and WordPress mysql passwords
rootmysqlpass=`dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev | tr -dc 'a-zA-Z0-9'`;
wpmysqlpass=`dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev | tr -dc 'a-zA-Z0-9'`;

# Update CentOS
yum -y update;
yum -y upgrade;

# Write passwords to file
echo "Root MySQL Password: $rootmysqlpass" > /root/passwords.txt;
echo "Wordpress MySQL Password: $wpmysqlpass" >> /root/passwords.txt;

# Install Nginx/MySQL
yum -y install epel-release;
yum -y install unzip nginx php-fpm php-mysql mariadb-server mariadb;

# Configure Nginx
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
cat > /etc/nginx/nginx.conf << "EOF"
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
      
events {
          worker_connections 1024;
}
      
http {
log_format  main    '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
access_log          /var/log/nginx/access.log  main;
sendfile            on;
tcp_nopush          on;
tcp_nodelay         on;
keepalive_timeout   65;
types_hash_max_size 2048;
include             /etc/nginx/mime.types;
default_type        application/octet-stream;
include             /etc/nginx/conf.d/*.conf;
}
EOF

# Configure PHP and PHP-FPM
sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php.ini
sed -i -e "s|listen = 127.0.0.1:9000|listen = /var/run/php-fpm/php-fpm.sock|" /etc/php-fpm.d/www.conf;
sed -i -e "s|user = apache|user = nginx|" /etc/php-fpm.d/www.conf;
sed -i -e "s|group = apache|group = nginx|" /etc/php-fpm.d/www.conf;

# Configure Nginx VirtualHost
cat > /etc/nginx/conf.d/default.conf << "EOF"
server {
listen 80 default_server;
listen [::]:80 default_server ipv6only=on;
root /var/www/html;
index index.php index.html index.htm;
server_name localhost;
 
location / {
    try_files $uri $uri/ /index.php?$args;
}

error_page 404 /404.html;
error_page 500 502 503 504 /50x.html;
location = /50x.html {
    root /usr/share/nginx/html;
}

location ~ \.php$ {
try_files $uri =404;
fastcgi_split_path_info ^(.+\.php)(/.+)$;
fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;
fastcgi_index index.php;
fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
include fastcgi_params;
}
}
EOF

# Download and uncompress WordPress
wget https://wordpress.org/latest.zip -O /tmp/wordpress.zip;
cd /tmp/;
unzip /tmp/wordpress.zip;

# Start services
systemctl start mariadb.service;
systemctl start nginx.service;
systemctl start php-fpm.service;

# Set up database user
/usr/bin/mysqladmin -u root -h localhost create wordpress;
/usr/bin/mysqladmin -u root -h localhost password $rootmysqlpass;
/usr/bin/mysql -uroot -p$rootmysqlpass -e "CREATE USER wordpress@localhost IDENTIFIED BY '"$wpmysqlpass"'";
/usr/bin/mysql -uroot -p$rootmysqlpass -e "GRANT ALL PRIVILEGES ON wordpress.* TO wordpress@localhost";

# Configure WordPress
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php;
sed -i "s/'DB_NAME', 'database_name_here'/'DB_NAME', 'wordpress'/g" /tmp/wordpress/wp-config.php;
sed -i "s/'DB_USER', 'username_here'/'DB_USER', 'wordpress'/g" /tmp/wordpress/wp-config.php;
sed -i "s/'DB_PASSWORD', 'password_here'/'DB_PASSWORD', '$wpmysqlpass'/g" /tmp/wordpress/wp-config.php;

for i in `seq 1 8`
do
wp_salt=$(</dev/urandom tr -dc 'a-zA-Z0-9!@#$%^&*()\-_ []{}<>~`+=,.;:/?|' | head -c 64 | sed -e 's/[\/&]/\\&/g');
sed -i "0,/put your unique phrase here/s/put your unique phrase here/$wp_salt/" /tmp/wordpress/wp-config.php;
done

mkdir -p /var/www/html
cp -Rf /tmp/wordpress/* /var/www/html/.;
rm -f /var/www/html/index.html;
rm -Rf /tmp/wordpress*;
chown -Rf nginx.nginx /var/www/html;

# Enabling services during start-up
systemctl enable mariadb.service;
systemctl enable php-fpm.service;
systemctl enable nginx.service;

# Restarting Nginx Service
systemctl restart nginx.service;
