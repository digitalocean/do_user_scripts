#!/bin/sh

# Source: https://github.com/mirzazeyrek/lemp-wordpress-stack
#
# WordPress Setup Script
#
# This script will install and configure WordPress on
# an Ubuntu 16.04 droplet
# Generate root and wordpress mysql passwords

export DEBIAN_FRONTEND=noninteractive;

#initial values
init() {
    pass_file='/root/mysql_passwd.txt'
    # leave sub_folder empty if you don't want to make installation to a subfolder
    sub_folder=""
    web_address="localhost"
    # for making an installation to www.mywebsite.com/myblog/
    #sub_folder="myblog"
    #web_address="www.mywebsite.com"

    multi_site=0
    # for multi site installation uncomment this line
    #multi_site=1
}

#creating installation folders
create_folders() {
    mkdir /var/www
    if [ "$sub_folder" != "" ]; then
        full_path="/var/www/$web_address/$sub_folder"
        mkdir /var/www/$web_address
        mkdir $full_path
    else
        full_path="/var/www/$web_address"
        mkdir $full_path
    fi
    #echo $full_path
}

#creating random passwords
set_passwords() {
    pass_file='/root/mysql_passwd.txt'
    touch pass_file
    root_mysql_passwd=`dd if=/dev/urandom bs=1 count=16 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev | tr -dc 'a-zA-Z0-9'`;
    wp_mysql_passwd=`dd if=/dev/urandom bs=1 count=8 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev | tr -dc 'a-zA-Z0-9'`;
    wp_mysql_user=`dd if=/dev/urandom bs=1 count=6 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev | tr -dc 'a-zA-Z0-9'`;
    wp_database=wp_`dd if=/dev/urandom bs=1 count=6 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev | tr -dc 'a-zA-Z0-9'`;
    echo "root mysql password: $root_mysql_passwd" >> $pass_file
    echo "wordpress password: $wp_mysql_passwd" >> $pass_file
    echo "wordpress user: $wp_mysql_user" >> $pass_file
    echo "wordpress database: $wp_database" >> $pass_file
}

get_passwords() {
    root_mysql_passwd=`sed -n "s/^.*root mysql password:\s*\(\S*\).*$/\1/p" $pass_file`;
    wp_mysql_passwd=`sed -n "s/^.*wordpress password:\s*\(\S*\).*$/\1/p" $pass_file`;
    wp_mysql_user=`sed -n "s/^.*wordpress user:\s*\(\S*\).*$/\1/p" $pass_file`;
    wp_database=`sed -n "s/^.*wordpress database:\s*\(\S*\).*$/\1/p" $pass_file`;
}

install_packages() {
    install_php_7
    install_mysql_57
    install_nginx
    install_unzip
    restart_packages
    echo "Installation Done."
}

restart_packages() {
    echo "Restarting Nginx, PHP-FPM and MySQL."
    sleep 1
    sudo systemctl restart php7.1-fpm
    service nginx restart
    service mysql restart
    echo "Packages restarted."
}

uff8_fix() {
    # use this function if you have any utf-8 related error with ondrej/php ppa
    echo "Fixing utf-8 error for ondrej/php package."
    sleep 1
    apt-get install -y language-pack-en-base
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
}

add_apt_repository() {
	# fixing add-apt-repository: command not found error 
	echo "fixing add-apt-repository: command not found error"
	sleep 1
	apt-get install -y software-properties-common python-software-properties
}

general_update() {
    echo "Updating packages."
    sleep 1
    apt-get update
    apt-get -y upgrade
}

install_unzip() {
    echo "Install unzip"
    sleep 1
    apt-get -y install unzip
}

install_mysql_57() {
    echo "Installing MySQL 5.7 Server and Client"
    sleep 1
    apt-get -y install debconf-utils
    echo mysql-server mysql-server/root_password password $root_mysql_passwd | sudo debconf-set-selections
    echo mysql-server mysql-server/root_password_again password $root_mysql_passwd | sudo debconf-set-selections
    sudo apt-get -y install mysql-server mysql-client
    apt-get -y install mysql-server-5.7
}

install_nginx() {
    echo "Installing Nginx webserver"
    sleep 1
    echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/nginx-stable.list
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C
    sudo apt-get update
    sudo apt-get -y install nginx
}

install_php_7() {
    echo "Adding ppa:ondrej/php repository as default PHP repository."
    sleep 1
    # -y flag means automatically say yes for command prompt.
    sudo add-apt-repository -y ppa:ondrej/php
    sudo apt-get update
    echo "Installing PHP 7.1 packages"
    sleep 1
    apt-get -y install screen build-essential libcurl3 libmcrypt4 libmemcached11 libxmlrpc-epi0 php7.1-cli php7.1-common php7.1-curl php7.1-fpm php7.1-gd php7.1-intl php7.1-json php7.1-mbstring php7.1-mcrypt php7.1-mysql php7.1-opcache php7.1-readline php7.1-xml php7.1-xmlrpc psmisc libmcrypt-dev mcrypt php-pear php-mysql php-mbstring php-mcrypt php-xml php-intl libmhash2 php-common php-memcached
}

set_packages()
{
    #updating packages again
    general_update
    get_wordpress
    set_mysql
    set_php_7
    set_nginx
    set_wordpress
}

get_wordpress() {
    # Download and uncompress WordPress
    if [ -d /tmp/wordpress/ ]; then
    rm -rf /tmp/wordpress/*
    fi
    echo "Downloading & Unzipping WordPress Latest Release"
    sleep 1
    wget https://wordpress.org/latest.zip -O /tmp/wordpress.zip;
    cd /tmp/ || exit;
    unzip /tmp/wordpress.zip;
}

set_mysql() {
    echo "Set up database user"
    #sleep 1
    # Set up database user
    /usr/bin/mysqladmin -u root -h localhost create $wp_database -p$root_mysql_passwd;
    /usr/bin/mysql -uroot -p$root_mysql_passwd -e "CREATE USER $wp_mysql_user@localhost IDENTIFIED BY '"$wp_mysql_passwd"'";
    /usr/bin/mysql -uroot -p$root_mysql_passwd -e "GRANT ALL PRIVILEGES ON $wp_database.* TO $wp_mysql_user@localhost";
}

set_php_7() {
    echo "set php 7.1"
    sleep 1
    # Configure PHP by mostly increasing default variables!
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.1/fpm/php.ini
    sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 20M/" /etc/php/7.1/fpm/php.ini
    sed -i "s/post_max_size = 8M/post_max_size = 20M/" /etc/php/7.1/fpm/php.ini
    sed -i "s/max_execution_time = 30/max_execution_time = 120/" /etc/php/7.1/fpm/php.ini
    sed -i "s/max_input_time = 60/max_input_time = 120/" /etc/php/7.1/fpm/php.ini
    sed -i "s/; max_input_vars = 1000/max_input_vars = 6000/" /etc/php/7.1/fpm/php.ini
    # Configure Opcache
    echo "opcache.memory_consumption=512" >> /etc/php/7.1/fpm/conf.d/10-opcache.ini
    echo "opcache.max_accelerated_files=50000" >> /etc/php/7.1/fpm/conf.d/10-opcache.ini
    echo "opcache.revalidate_freq=0" >> /etc/php/7.1/fpm/conf.d/10-opcache.ini
    echo "opcache.consistency_checks=1" >> /etc/php/7.1/fpm/conf.d/10-opcache.ini
    #sed -i "s|listen = 127.0.0.1:9000|listen = /var/run/php5-fpm.sock|" /etc/php5/fpm/pool.d/www.conf;
    sudo systemctl restart php7.1-fpm
}

set_nginx() {
    echo "Configuring nginx settings"
    sleep 1
    cp -avr /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
    cp -avr /etc/nginx/sites-available/default.bak /etc/nginx/sites-available/$web_address
    #rm -avr /etc/nginx/sites-available/default
    # adding multi site redirections
    if [ "$sub_folder" != "" ] && [ "$multi_site" = "1" ]
    then
        echo "multi site with sub folder"
        sed -i "s/server_name _;/server_name _;\n\tif (!-e \$request_filename) {\n\t\trewrite \/wp-admin\$ \$scheme:\/\/\$host\$uri\/ permanent;\n\t\trewrite \^\/$sub_folder(\/\[^\/\]+)\?(\/wp-.*) \/$sub_folder\$2 last;\n\t\trewrite \^\/$sub_folder(\/\[^\/\]+)\?(\/.*\.php)\$ \/$sub_folder\$2 last;\n\t}/" /etc/nginx/sites-available/$web_address;
    fi
    if [ "$sub_folder" = "" ] && [ "$multi_site" = "1" ]
    then
        echo "multi site without sub folder"
        sed -i "s/server_name _;/server_name _; \n\tif (!-e \$request_filename) {\n\t\trewrite \/wp-admin\$ \$scheme:\/\/\$host\$uri\/ permanent;\n\t\trewrite \^(\/\[^\/\]+)\?(\/wp-.*) \$2 last;\n\t\trewrite \^(\/\[^\/\]+)\?(\/.*\.php)\$ \$2 last;\n\t}/" /etc/nginx/sites-available/$web_address
    fi
    # adding subfolder redirections
    if [ "$sub_folder" != "" ]; then
    sed -i "s/server_name _;/server_name _;\n\n\tlocation \/$sub_folder {\n\t\tindex index.php;\n\t\ttry_files \$uri \$uri\/ \/$sub_folder\/index.php\?\$args;\n\t}/" /etc/nginx/sites-available/$web_address
    fi
    # log and browser cache settings
    sed -i "s/server_name _;/server_name _;\n\n\tlocation = \/favicon.ico {\n\t\tlog_not_found off;\n\t\taccess_log off;\n\t}/" /etc/nginx/sites-available/$web_address
    sed -i "s/server_name _;/server_name _;\n\n\tlocation = \/robots.txt {\n\t\tlog_not_found off;\n\t\taccess_log off;\n\t}/" /etc/nginx/sites-available/$web_address
    sed -i "s/server_name _;/server_name _;\n\n\tlocation ~* \\\.(js|css|ogg\|ogv\|svg\|svgz\|eot\|otf\|woff\|mp4\|ttf\|rss\|atom\|jpg\|jpeg\|gif\|png\|ico\|zip\|tgz\|gz\|rar\|bz2\|doc\|xls\|exe\|ppt\|tar\|mid\|midi\|wav\|bmp\|rtf)\$ {\n\t\texpires 30d;\n\t\tlog_not_found off;\n\t}/" /etc/nginx/sites-available/$web_address
    # activate gzip
    if [ ! -f /etc/nginx/nginx.conf.bak ]; then
    cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
    fi
    cp /etc/nginx/nginx.conf.bak /etc/nginx/nginx.conf
    sed -i "s/# gzip_vary on;/gzip_vary on;/" /etc/nginx/nginx.conf
    sed -i "s/# gzip_proxied any;/gzip_proxied any;/" /etc/nginx/nginx.conf
    sed -i "s/# gzip_comp_level 6;/gzip_comp_level 6;/" /etc/nginx/nginx.conf
    sed -i "s/# gzip_buffers 16 8k;/gzip_buffers 16 8k;/" /etc/nginx/nginx.conf
    sed -i "s/# gzip_http_version 1.1;/gzip_http_version 1.1;/" /etc/nginx/nginx.conf
    sed -i "s/# gzip_min_length 256;/gzip_min_length 256;/" /etc/nginx/nginx.conf
    sed -i "s/# gzip_types text\/plain/gzip_types text\/plain application\/vnd.ms\-fontobject application\/x-font-ttf font\/opentype image\/svg+xml image\/x-icon/" /etc/nginx/nginx.conf
    # set file upload settings 20 M and 6 min max
    sed -i "s/sendfile on;/sendfile on;\n\tclient_max_body_size 20M;/" /etc/nginx/nginx.conf
    sed -i "s/sendfile on;/sendfile on;\n\tsend_timeout 360s;/" /etc/nginx/nginx.conf
    # making default settings
    sed -i "s/try_files \$uri \$uri\/ =404;/try_files \$uri \$uri\/ \/index.php\$is_args\$args;/" /etc/nginx/sites-available/$web_address
    sed -i "s/server_name _;/server_name $web_address;/" /etc/nginx/sites-available/$web_address
    sed -i "s/root \/var\/www\/html;/root \/var\/www\/$web_address;/" /etc/nginx/sites-available/$web_address
    sed -i "s/index index.html/index index.php index.html/" /etc/nginx/sites-available/$web_address
    # replacing default server if it's not localhost
    if [ "$web_address" != "localhost" ]; then
    sed -i "s/listen 80 default_server;/listen 80;/" /etc/nginx/sites-available/$web_address
    sed -i "s/listen \[\:\:\]\:80 default_server;/listen \[\:\:\]\:80;/" /etc/nginx/sites-available/$web_address
    fi
    # adding .php connection to the nginx
    sed -i "s/#location ~ \\\.php\$ {/location ~ \\\.php\$ {/" /etc/nginx/sites-available/$web_address
    sed -i "s/#\tinclude snippets\/fastcgi-php.conf;/\tinclude snippets\/fastcgi-php.conf;/" /etc/nginx/sites-available/$web_address
    sed -i "s/#\tfastcgi_pass unix:\/var\/run\/php\/php7.0-fpm.sock;/\tfastcgi_pass unix:\/run\/php\/php7.1-fpm.sock;\n\t\tinclude fastcgi_params;/" /etc/nginx/sites-available/$web_address
    # blocking access from .htaccess
    sed -i "s/#location ~ \/\\\.ht {/location ~ \/\\\.ht {/" /etc/nginx/sites-available/$web_address
    sed -i "s/#\tdeny all;/\tdeny all;/" /etc/nginx/sites-available/$web_address
    # closing the gap for previous nginx and htaccess settings
    sed -i "s/\t#}/\t}/" /etc/nginx/sites-available/$web_address
    mv /etc/nginx/sites-available/$web_address /etc/nginx/sites-enabled/$web_address
    touch /var/www/$web_address/info.php
    echo "<?php phpinfo();?>" > /var/www/$web_address/info.php
    echo /var/www/$web_address/info.php
    rm /etc/nginx/sites-enabled/default
    sudo systemctl reload nginx
}

set_wordpress() {
    echo "Configuring WordPress"
    sleep 1
    rm -rf $full_path/*
    mv /tmp/wordpress/* $full_path
    cp $full_path/wp-config-sample.php $full_path/wp-config.php;
    if [ "$multi_site" = "1" ]; then
        sed -i "s/'WP_DEBUG', false);/'WP_DEBUG', false);\r\ndefine('WP_ALLOW_MULTISITE', true);/" $full_path/wp-config.php;
    else
        echo "multi site is disabled"
        sleep 1
    fi
    sed -i "s/'WP_DEBUG', false);/'WP_DEBUG', false);\r\ndefine('WP_MEMORY_LIMIT', '96M');/" $full_path/wp-config.php;
    sed -i "s|'DB_NAME', 'database_name_here'|'DB_NAME', '$wp_database'|g" $full_path/wp-config.php;
    sed -i "s/'DB_USER', 'username_here'/'DB_USER', '$wp_mysql_user'/g" $full_path/wp-config.php;
    sed -i "s/'DB_PASSWORD', 'password_here'/'DB_PASSWORD', '$wp_mysql_passwd'/g" $full_path/wp-config.php;
    db_prefix=`dd if=/dev/urandom bs=1 count=3 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev | tr -dc 'a-zA-Z0-9'`_;
    echo "db_prefix : $db_prefix ";
    sleep 1;
    sed -i "s/\$table_prefix  = 'wp_';/\$table_prefix  = '$db_prefix';/" $full_path/wp-config.php;
    for i in `seq 1 8`
    do
    wp_salt=$(</dev/urandom tr -dc 'a-zA-Z0-9!@#$%^&*()\-_ []{}<>~`+=,.;:/?|' | head -c 64 | sed -e 's/[\/&]/\\&/g');
    sed -i "0,/put your unique phrase here/s/put your unique phrase here/$wp_salt/" $full_path/wp-config.php;
    done
    chown -Rf www-data:www-data $full_path;
}

set_wordpress_multisite() {
        echo "Configuring WordPress Multisite Settings"
        sleep 1
        sed -i "s/'WP_DEBUG', false);/'WP_DEBUG', false);\r\ndefine('BLOG_ID_CURRENT_SITE', 1);/" $full_path/wp-config.php;
        sed -i "s/'WP_DEBUG', false);/'WP_DEBUG', false);\r\ndefine('SITE_ID_CURRENT_SITE', 1);/" $full_path/wp-config.php;
        if [ "$sub_folder" != "" ]; then
           sed -i "s/'WP_DEBUG', false);/'WP_DEBUG', false);\r\ndefine('PATH_CURRENT_SITE', '\/$sub_folder\/');/" $full_path/wp-config.php;
         else
            sed -i "s/'WP_DEBUG', false);/'WP_DEBUG', false);\r\ndefine('PATH_CURRENT_SITE', '\/');/" $full_path/wp-config.php;
        fi
        sed -i "s/'WP_DEBUG', false);/'WP_DEBUG', false);\r\ndefine('DOMAIN_CURRENT_SITE', '$web_address');/" $full_path/wp-config.php;
        sed -i "s/'WP_DEBUG', false);/'WP_DEBUG', false);\r\ndefine('SUBDOMAIN_INSTALL', false);/" $full_path/wp-config.php;
        sed -i "s/'WP_DEBUG', false);/'WP_DEBUG', false);\r\ndefine('MULTISITE', true);/" $full_path/wp-config.php;
}

rm_temp() {
    echo "Removing temp files"
    sleep 1
    rm -rf /tmp/wordpress
    rm /tmp/wordpress.zip
}

uff8_fix
add_apt_repository
init
create_folders
set_passwords
get_passwords
install_packages
set_packages
restart_packages
rm_temp

echo "all set.";
