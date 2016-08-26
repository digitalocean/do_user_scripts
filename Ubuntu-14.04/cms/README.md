# CMS Scripts

##wordpress.sh
This script will install and configure Wordpress.  This stack includes Apache2, PHP5, and MySQL. 

## mediawiki.sh
This script will install and configure MediaWiki with Apache, PHP, and MySQL.  Details on the database user created can be found in the MOTD shown when you log in via ssh.  After this script is complete you can browse to your new droplet's IP address to complete the setup.

## wordpress-openlitespeed.sh
This script will install and configure wordpress on top of LOMP stack (Linux, OpenLiteSpeed, MySQL, LSPHP) with a single click. It's intended to be used with a FRESHLy created Ubuntu 14 DigitalOcean droplet. The only thing user needs to do is log into the wordpress admin page and customize the site. Detailed instructions and credentials will be provided on terminal during installation. Two php version available: default is lsphp56, optional lsphp70.
