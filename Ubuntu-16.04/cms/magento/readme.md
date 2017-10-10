#Magento, nginx, mariadb, Let's Encrypt on Ubuntu

This script is meant to automate installation and initial configuration of Magento, nginx, mariadb, and Let's Encrypt via [cloud-init](https://www.digitalocean.com/community/tutorials/an-introduction-to-cloud-config-scripting)
on an Ubuntu 16.04 or 17.04 server.


## Prerequisites:
Before running this, you'll need to:
1. Configure your domain to point at DigitalOcean Nameservers
   [ref](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-host-name-with-digitalocean)
2. Add your top-level domain _(domain.com, no subdomain)_ in [DigitalOcean control panel](https://cloud.digitalocean.com/networking/domains).
3. Replace <%YOUR_TOP_LEVEL_DOMAIN.COM%> below with your top-level domain (domain.com)
4. Replace <%YOUR_DIGITALOCEAN_API_KEY%> with an API token. [Ref](https://cloud.digitalocean.com/settings/api/tokens)
When creating the server, you'll need to use an Ubuntu 16.04 or 17.04 image with at least 1GB Memory.


## Deploy Plan:
By pasting [cloud-init.yaml](cloud-init.yaml) into user-data section of server create page, server will automatically:

1. Install and start [nginx](https://www.digitalocean.com/community/tags/nginx)
2. Update DigitalOcean DNS to point a subdomain [this_server_name].[your_top_level_domain.com]
   at public IPV4 of this server.
3. Install and run [Let's Encrypt](https://www.digitalocean.com/community/tags/let-s-encrypt) certbot tool to automatically generate and renew SSL
   certificates (allowing magento to run only via HTTPS)
4. Install, configure and run [mariaDB](https://www.digitalocean.com/community/tags/mariadb)
5. Download the latest release of magento, install required packages and change required config settings.

Install takes ~4 minutes, once server is created you can SSH in and follow progress by running `tail -f /var/log/cloud-init-output.log`. Once install is finished you can go to https://[subdomain].[your-domain.com] and finish the magento configuration. For database config, you will need to specify:
 - Database Server Host: `localhost`
 - Database Server Username: `magento_user`
 - Database Server Password: _Password is displayed when you login to server or in `/etc/motd`_
 - Database Name: magento
 - Table prefix: _leave empty_

 *When setting store URL, don't forget to switch to secure httpS protocol!*


## Further Reading:
This script builds on detailed instructions provided in the following tutorials:
- [Install and configure Magento on Ubuntu](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-magento-on-ubuntu-14-04)
- [Install Let's Encrypt (certbot) with nginx on ubuntu](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-16-04)
- [Setup Magento behind an nginx reverse proxy](https://www.howtoforge.com/tutorial/how-to-install-magento-with-nginx-on-ubuntu/)
- You'll likely need to [configure SMTP in Magento](https://docs.nexcess.net/article/how-to-set-up-outgoing-smtp-email-for-magento.html) to send emails.