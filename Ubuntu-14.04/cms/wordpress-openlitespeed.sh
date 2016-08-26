#!/bin/bash

##############################################################################
#    Copyright (C) 2013 - 2016 LiteSpeed Technologies, Inc.                  #
#                                                                            #
#    This program is free software: you can redistribute it and/or modify    #
#    it under the terms of the GNU General Public License (version 3) as     #
#    published by the Free Software Foundation.                              #
#                                                                            #
#    This program is distributed in the hope that it will be useful,         #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of          #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the            #
#    GNU General Public License for more details.                            #
#                                                                            #
#    You should have received a copy of the GNU General Public License       #
#    along with this program. If not, see http://www.gnu.org/licenses/.      #
#                                                                            #
##############################################################################


#
#
# Program:
#	This script to be used with a freshly created DigitalOcean ubuntu 14 droplet.
#	It will install OpenLiteSpeed web server, lsphp56 or lsphp70 (php with lsapi),
#	mysql and wordpress with one click. This script is output of the first time
#	working together by LiteSpeed and DigitalOcean community team.
#
# Version:
#	Current version is 1.0.0
#
# History:
#	2016-8-25 Initial release 1.0.0
#
# Author:
#	LiteSpeed Tech (info@litespeedtech.com)
#
#

export DEBIAN_FRONTEND=noninteractive

showLiteSpeed() {

	cat << EOLOGO


                                       [93;1m.+[0m
                                      [93;1m''[0m
                                     [93;1m':[0m
                                   [93;1m,::[0m
             [95;1m##                   [93;1m+::,[0m 
             [95;1m##    ## ##### #### [93;1m;::+[0m   [95;1m###, #### #### #####.[0m
             [95;1m##    ##   #   ##   [93;1m'::+[0m   [95;1m#  # ##   ##   ##   #,[0m
             [95;1m##    ##   #   ##    [93;1m+::,[0m  [95;1m#  # ##   ##   ##   ##[0m
             [95;1m##    ##   #   ####   [93;1m+::[0m  [95;1m###' #### #### ##   ##[0m
             [95;1m##    ##   #   ##      [93;1m::'[0m [95;1m#    ##   ##   ##   ##[0m
             [95;1m##    ##   #   ##     [93;1m;::+[0m [95;1m#    ##   ##   ##   #'[0m
             [95;1m##### ##   #   ####  [93;1m'::,[0m  [95;1m#    #### #### #####[0m
                                 [93;1m+:+[0m
                                [93;1m+::[0m
                               [93;1m++[0m
                              [93;1m+:[0m
                             [93;1m.[0m

EOLOGO

}

echos()
{
	STYLE_CODE=$1

	ForeColor=${STYLE_CODE:0:1}
	Style=${STYLE_CODE:1:1}
	BackColor=${STYLE_CODE:2:1}

	case $ForeColor in
		'k') ForeCode=30 ;;
		'r') ForeCode=31 ;;
		'g') ForeCode=32 ;;
		'y') ForeCode=33 ;;
		'i') ForeCode=34 ;;
		'p') ForeCode=35 ;;
		'b') ForeCode=36 ;;
		'w') ForeCode=37 ;;
		'K') ForeCode=90 ;;
		'R') ForeCode=91 ;;
		'G') ForeCode=92 ;;
		'Y') ForeCode=93 ;;
		'I') ForeCode=94 ;;
		'P') ForeCode=95 ;;
		'B') ForeCode=96 ;;
		'W') ForeCode=97 ;;
		*) ForeCode=37 ;;
	esac	

	case $Style in
		'1')  ;;
		'3')  ;;
		'4')  ;;
		'5')  ;;
		*) Style=$ForeCode ;;
	esac

	case $BackColor in
		'k') BackCode=40 ;;
		'r') BackCode=41 ;;
		'g') BackCode=42 ;;
		'y') BackCode=43 ;;
		'i') BackCode=44 ;;
		'p') BackCode=45 ;;
		'b') BackCode=46 ;;
		'w') BackCode=47 ;;
		'K') BackCode=100 ;;
		'R') BackCode=101 ;;
		'G') BackCode=102 ;;
		'Y') BackCode=103 ;;
		'I') BackCode=104 ;;
		'P') BackCode=105 ;;
		'B') BackCode=106 ;;
		'W') BackCode=107 ;;
		*) BackCode=40 ;;
	esac	

	shift;

	echo -e "\x1b[${ForeCode};${Style};${BackCode}m$@\x1b[0m"

}


flashScreen()
{
	while true; do 
		printf \\e[?5h;
		sleep 0.1;
		printf \\e[?5l;
		read -s -n1 -t1 && break;
	done;
}

showWelcome()
{
	echo
	echo
	echos g "##############################################################################"
	echos g "#                                                                            #"
	echos g "#                        [32;1mWelcome to LiteSpeed ![0m                              [32m#"
	echos g "#                                                                            #"
	echos g "#                        [33mSave time, save life[0m                                [32m#"
	echos g "#                                                                            #"
	echos g "#                [33m-- Share the dedication to web accelaration[0m                 [32m#"
	echos g "#                                                                            #"
	echos g "#                                                                            #"
	echos g "#                        [36;4mWord of the script[0m                                  [32m#"
	echos g "#                                                                            #"
	echos g "#                 [33mLOVE is what makes us great   --  by DigitalOcean  [0m        [32m#"
	echos g "#                                                                            #"
	echos g "#                                                                            #"
	echos g "#                     [35;3mDistributed under GPLv3 License[0m                        [32m#"
	echos g "#                                                                            #"
	echos g "##############################################################################"
	
	
	sleep 3 
}


usage()
{
	echo
	echos b "This script is intended to be used on a freshly deployed DO"
	echos b "Ubuntu 14 droplet. It will install LOMP stack with WordPress."
	echo
	echos b "If you want to install lsphp70 instead of default lsphp56,"
	echos b "please use the lsphp70 option: $0 lsphp70"
	echos b "Otherwise there is no option needed"
	echo
}

if [ $# -gt 1 ] || [ $# -eq 1 -a "$1" != 'lsphp70' ]; then
	usage
	exit 1
fi 

if [ `id -u` != 0 ]; then
        echos R "Please run this script as root user !"
        exit 1
fi



showLiteSpeed
showWelcome

echo
echo
echos y "##################### Functional script starts ####################"
echo
echo

###*********************************************************************************###
###*********************************************************************************###

	######### Functional script content start from here #########

###*********************************************************************************###
###*********************************************************************************###

DATE=`date`

echo
echos b "Start time : $DATE"
echo

MYSQL_ROOT_PWD=`echo "$RANDOM$DATE" | md5sum | base64 | head -c 8`
MYSQL_DBUSER_PWD=`echo "$RANDOM$DATE" | md5sum | base64 | head -c 8`

OLS_ADMIN_PWD=`echo "$RANDOM$DATE" | md5sum | base64 | head -c 8`
WP_ADMIN_PWD=`echo "$RANDOM$DATE" | md5sum | base64 | head -c 8`

WP_IP=`ip a | grep -m 1 'scope global eth0' | awk '{print $2}' | cut -d'/' -f 1`

echo
echos p "************************************************"
echo
echos p "MySQL Root Password is : $MYSQL_ROOT_PWD"
echos p "MySQL WPDB Password is : $MYSQL_DBUSER_PWD"
echo
echos p "OpenLiteSpeed WebAdmin Password is : $OLS_ADMIN_PWD"
echo
echos p "WordPress Admin Password is: $WP_ADMIN_PWD"
echo
echos p "************************************************"

WP_DB_NAME=wordpress
WP_DB_USER=wpdbuser

SERVER_ROOT=/usr/local/lsws
VH_ROOT=$SERVER_ROOT/wordpress
WP_DOC_ROOT=/var/www/html/wordpress

echo
echos y "Enable LiteSpeed repo for trusty"
echo "deb http://rpms.litespeedtech.com/debian/ trusty main" > /etc/apt/sources.list.d/lst_debian_repo.list
wget -O /etc/apt/trusted.gpg.d/lst_debian_repo.gpg http://rpms.litespeedtech.com/debian/lst_debian_repo.gpg &> /dev/null
echos y "Done"
echo
echo
echos y "Start apt-get update and upgrade"
echos y "This may take a few minutes. Please wait ..."
echo
apt-get update > /dev/null
echos y "  Update done"	
apt-get -y upgrade > /dev/null
echos y "  Upgrade done"
echo
echos y "Repo update and package upgrade finished"
echo

# Install packages

if [ "$1" == 'lsphp70' ];then
	LSPHP_VER=70
else
	LSPHP_VER=56
fi

echo
echos y "Installing OpenLiteSpeed, MySQL, LSPHP$LSPHP_VER, etc"
echos y "This may take a few minutes. Please wait ..."
if [ "$LSPHP_VER" == '70' ];then
	apt-get -y -f --force-yes install openlitespeed \
			   mysql-server mysql-client \
			   lsphp$LSPHP_VER-common lsphp$LSPHP_VER \
			   lsphp$LSPHP_VER-mysql lsphp$LSPHP_VER-imap \
			   php5-cli php5-mysql \
			   &> /dev/null	
else
	apt-get -y -f --force-yes install openlitespeed \
			   mysql-server mysql-client \
			   lsphp$LSPHP_VER \
			   lsphp$LSPHP_VER-gd lsphp$LSPHP_VER-mysql \
			   lsphp$LSPHP_VER-mcrypt lsphp$LSPHP_VER-imap \
			   php5-cli php5-mysql \
			   &> /dev/null	
fi

echo
echos y "Package installation finished"
echo

echo
echos y "Configure database and openlitespeed"
echo


# Set MySQL root password
echos y "  Set MySQL root password"
mysqladmin -u root password $MYSQL_ROOT_PWD > /dev/null
echos y "  Done"

# Set up database for wp installation
echo
echos y "  Set up database for wp installation"
mysql -uroot -p$MYSQL_ROOT_PWD -e "CREATE DATABASE IF NOT EXISTS $WP_DB_NAME;" > /dev/null
mysql -uroot -p$MYSQL_ROOT_PWD -e "CREATE USER $WP_DB_USER@localhost IDENTIFIED BY '$MYSQL_DBUSER_PWD';" > /dev/null
mysql -uroot -p$MYSQL_ROOT_PWD -e "GRANT ALL PRIVILEGES ON $WP_DB_NAME.* TO '$WP_DB_USER'@localhost IDENTIFIED BY '$MYSQL_DBUSER_PWD';" > /dev/null
echos y "  Done"


# Config openlitespeed to install wordpress
echo
echos y "  Configure OpenLiteSpeed for wordpress installation"
ln -sf $SERVER_ROOT/lsphp$LSPHP_VER/bin/lsphp  $SERVER_ROOT/fcgi-bin/lsphp5

mkdir -p $VH_ROOT
mkdir -p $SERVER_ROOT/conf/vhosts/wordpress/
VHOSTCONF=$SERVER_ROOT/conf/vhosts/wordpress/vhconf.conf

cat >> $SERVER_ROOT/conf/httpd_config.conf <<END

        virtualhost wordpress {
        vhRoot                  $VH_ROOT
        configFile              $VHOSTCONF
        allowSymbolLink         1
        enableScript            1
        restrained              0
        setUIDMode              2
        }

        listener wordpress {
        address                 *:80
        secure                  0
        map                     wordpress *
        }

        module cache {
        param <<<PARAMFLAG
        enableCache         0
        qsCache             1
        reqCookieCache      1
        respCookieCache     1
        ignoreReqCacheCtrl  1
        ignoreRespCacheCtrl 0
        enablePrivateCache  0
        privateExpireInSeconds 1000
        expireInSeconds     1000
        storagePath cachedata
        checkPrivateCache   1
        checkPublicCache    1
PARAMFLAG
}

END

cat > $VHOSTCONF <<END
        docRoot                   /var/www/html/wordpress
        index  {
          useServer               0
          indexFiles              index.php
        }

        rewrite  {
          enable                  1
          rules                   rewriteFile  /var/www/html/wordpress/.htaccess
        }

END
echos y "  Done"

echo
echos y "  Set up OpenLiteSpeed WebAdmin user and credential"
TEMP=`/usr/local/lsws/admin/fcgi-bin/admin_php /usr/local/lsws/admin/misc/htpasswd.php $OLS_ADMIN_PWD`
echo "admin:$TEMP" > /usr/local/lsws/admin/conf/htpasswd
chown -R lsadm:lsadm $SERVER_ROOT/conf/
echos y "  Done"

echo
echos y "LOMP configuration finished !"


# Installing wordpress, including core and lscache plug in

echo
echo
echos y "Installing wordpress..."
echo

mkdir -p $WP_DOC_ROOT
cd $WP_DOC_ROOT
chown -R nobody:nogroup $WP_DOC_ROOT

# Download wp-cli
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar &> /dev/null
chmod +x wp-cli.phar
mv -f wp-cli.phar /usr/local/bin/wp

# Install wordpress core
sudo -u nobody wp core download

cp wp-config-sample.php  wp-config.php

sed -i -e "s/'DB_NAME', 'database_name_here'/'DB_NAME','$WP_DB_NAME'/g" \
       -e "s/'DB_USER', 'username_here'/'DB_USER', '$WP_DB_USER'/g" \
       -e "s/'DB_PASSWORD', 'password_here'/'DB_PASSWORD', '$MYSQL_DBUSER_PWD'/g" \
       wp-config.php		

sed -i "/WP_DEBUG/a define('WP_CACHE',true);" wp-config.php

# Generate and append unique phrase
curl -s https://api.wordpress.org/secret-key/1.1/salt/ > temp \
&& sed -i '/put your unique phrase here/R temp' wp-config.php \
&& rm -f temp \
&& sed -i '/put your unique phrase here/d' wp-config.php

# Install wp core and plugin  
sudo -u nobody wp core install --url=$WP_IP --title="LOVE is what makes us great" --admin_user=admin --admin_email=root@local.host --admin_password=$WP_ADMIN_PWD
sudo -u nobody wp plugin install "litespeed-cache" --activate --force

chown -R nobody:nogroup $WP_DOC_ROOT
echo
echos y "Done"

# Restart openlitespeed
echo
echo
echos y "Restarting openlitespeed"
service lsws restart > /dev/null
echos y "Done"
echo

# Save passwords and other info to record file
echo
echos y "Save credentials to record file"

RECORD_FILE=/root/ols-wp-record
echo > $RECORD_FILE
echos p "Installation record for ols-wp:" >> $RECORD_FILE
echo >> $RECORD_FILE
echo >> $RECORD_FILE
echos p "************************************************" >> $RECORD_FILE
echo >> $RECORD_FILE
echos p "MySQL" >> $RECORD_FILE
echo >> $RECORD_FILE
echos p "  Root Password : $MYSQL_ROOT_PWD" >> $RECORD_FILE
echo >> $RECORD_FILE
echos p "  WordPress Database : $WP_DB_NAME" >> $RECORD_FILE
echos p "  WordPress DB User  : $WP_DB_USER" >> $RECORD_FILE 
echos p "  WPDB User Password : $MYSQL_DBUSER_PWD" >> $RECORD_FILE
echo >> $RECORD_FILE
echos p "OpenLiteSpeed WebAdmin" >> $RECORD_FILE
echos p "  Admin User Name : admin" >> $RECORD_FILE
echos p "  Admin Password  : $OLS_ADMIN_PWD" >> $RECORD_FILE
echo >> $RECORD_FILE
echos p "WordPress" >> $RECORD_FILE
echos p "  Admin User Name : admin" >> $RECORD_FILE
echos p "  Admin Password  : $WP_ADMIN_PWD" >> $RECORD_FILE
echo >> $RECORD_FILE
echos p "************************************************" >> $RECORD_FILE

chmod 600 $RECORD_FILE

echos y "Done"

# Success message
echo
echo
echo
echos G1 "		Congratulations !"
echo
echo
echos g "The installation of wordpress on LOMP stack succeeds ^_^"
echo
echos g "You can visit the site now: http://$WP_IP"
echo
echos g "The WP admin page url is: http://$WP_IP/wp-admin"
echo
echos g "Just go head and enjoy the freedom of customizing your site !"
echo
echos g "The OpenLiteSpeed WebAdmin url: https://$WP_IP:7080"
echo
echos g "All credentials have been saved to /root/ols-wp-record"
echo
sleep 2
echo
cat /root/ols-wp-record
echo
echo
echos G3 "Happy serving, happy coding ! On LOMP !"
echo
echo
echo
echos b `date`
echo
echo
echo
# End of script
