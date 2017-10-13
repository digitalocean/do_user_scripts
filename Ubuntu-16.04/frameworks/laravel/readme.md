# Run Laravel, nginx, MySQL, Let's Encrypt on Ubuntu

This script starts with an Ubuntu 16.04 or 17.04 server and finishes with a laravel app and mysql database running behind nginx with HTTPS using [cloud-init](https://www.digitalocean.com/community/tutorials/an-introduction-to-cloud-config-scripting).


## Prerequisites:
Before running this, you'll need to:
1. Configure your domain to [point at DigitalOcean Nameservers](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-host-name-with-digitalocean)
2. Add your top-level domain _(domain.com, no subdomain)_ in [DigitalOcean control panel](https://cloud.digitalocean.com/networking/domains).
3. Replace [<%YOUR_TOP_LEVEL_DOMAIN.COM%>](cloud-init.yaml#L16) with your top-level domain (domain.com)
4. Replace [<%YOUR_DIGITALOCEAN_API_TOKEN%>](cloud-init.yaml#L17) with an API token. [Get one here.](https://cloud.digitalocean.com/settings/api/tokens)
5. This will use the [laravel quickstart example](https://github.com/laravel/quickstart-basic) app by default, but you can [change the github repo](cloud-init.yaml#L19) to another laravel/mysql app if you like.


## Deploy Plan:
Once prerequisites are met, paste [cloud-init.yaml](cloud-init.yaml) into user-data section on droplet create page. Once booted, server will:

1. Install and start [nginx](https://www.digitalocean.com/community/tags/nginx)
2. Install, configure and run [mysql](https://www.digitalocean.com/community/tags/mysql)
3. Clone the laravel example app from github, configure and initialize it.
2. Update DigitalOcean DNS to point a subdomain [this_droplet_name].[your_top_level_domain.com]
at public IPV4 address of this server.
3. Install and run [Let's Encrypt](https://www.digitalocean.com/community/tags/let-s-encrypt) certbot tool to automatically generate and renew SSL
certificates (allowing magento to run only via HTTPS)

Install takes ~3 minutes, once server is created you can SSH in and follow progress by running `tail -f /var/log/cloud-init-output.log`. Once install is finished you can go to https://[this_droplet_name].[your_top_level_domain.com] and confirm that the app is running correctly.

## Further Reading:
This is meant to be used as scaffolding to get going quickly, it builds on detailed instructions provided in the following tutorials:
- [Install nginx, mysql, php on Ubuntu](https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-in-ubuntu-16-04)
- [Install Let's Encrypt (certbot) with nginx on ubuntu](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-16-04)
- [Deploy a Laravel Application on Ubuntu](https://www.digitalocean.com/community/tutorials/how-to-deploy-a-laravel-application-with-nginx-on-ubuntu-16-04)
