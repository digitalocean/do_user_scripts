# CMS Scripts

##wordpress.sh
This script will install and configure Wordpress.  This stack includes Apache2, PHP5, and MySQL. 

## mediawiki.sh
This script will install and configure MediaWiki with Apache, PHP, and MySQL.  Details on the database user created can be found in the MOTD shown when you log in via ssh.  After this script is complete you can browse to your new droplet's IP address to complete the setup.

## wordpress-openlitespeed.sh
This script will install and configure WordPress with OpenLiteSpeed, LSPHP and MariaDB with a single click. The only thing the user may want to do is log into the WordPress admin dashboard and customize the site. 

The script will appear to complete, but will need up to 3 more minutes to actually finish. After this time, browsing to your droplet's assigned IP will take you to your WordPress site.

_Note: Settings, such as the site title, the domain, and so on can be changed from the WordPress admin dashboard._
