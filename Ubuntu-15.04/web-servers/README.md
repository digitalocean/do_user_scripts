Web Servers
===========

lamp.yml
---------------

Installs a basic ["LAMP" stack](https://www.digitalocean.com/community/tutorials/how-to-install-linux-apache-mysql-php-lamp-stack-on-ubuntu-14-04) with Apache, PHP, and MySQL.


lemp.yml
---------------

Installs and configures a basic ["LEMP" stack](https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-on-ubuntu-14-04) with Nginx and PHP-FPM.


lamp-phpmyadmin.yml
---------------

Installs a basic ["LAMP" stack](https://www.digitalocean.com/community/tutorials/how-to-install-linux-apache-mysql-php-lamp-stack-on-ubuntu-14-04) with Apache, PHP, and MySQL. In addition, [phpMyAdmin](https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-on-ubuntu-14-04) is also installed and configured. The file `/root/phpmyadmin` contains the automatically generated passwords for both the MySql root user and the `.htaccess` file protecting the phpMyAdmin login page.


tomcat7.yml
-----------

Installs a basic [Tomcat 7 web server](https://www.digitalocean.com/community/tutorials/how-to-install-apache-tomcat-7-on-ubuntu-14-04-via-apt-get). The file `/root/tomcat` contains the automatically generated password to access the web managment interface.