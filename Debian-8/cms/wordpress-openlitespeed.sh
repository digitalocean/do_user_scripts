#!/bin/sh
curl -k -o /tmp/ols1clk.sh https://raw.githubusercontent.com/litespeedtech/ols1clk/master/ols1clk.sh
chmod 700 /tmp/ols1clk.sh
export IPADD=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{print $1}'`
/tmp/ols1clk.sh --wordpressplus $IPADD  --quiet
cp /usr/local/lsws/password /root/passwords.txt
