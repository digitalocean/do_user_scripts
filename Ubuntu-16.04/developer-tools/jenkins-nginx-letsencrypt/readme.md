# Jenkins, nginx, and HTTPS via Let's Encrypt on Ubuntu 16.x

This script is meant to automate installation and initial configuration of Jenkins, nginx and Let's Encrypt via [cloud-init](https://www.digitalocean.com/community/tutorials/an-introduction-to-cloud-config-scripting) on an Ubuntu 16.04 or 16.10 server.

## Prerequisites:
Before running this, you'll need to:
1. Configure your domain to point at DigitalOcean Nameservers
 [ref](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-host-name-with-digitalocean)
2. Add your top-level domain _(domain.com, no subdomain)_ in [DigitalOcean control panel](https://cloud.digitalocean.com/networking/domains).
3. Replace <%YOUR_TOP_LEVEL_DOMAIN.COM%> in the [cloud-init.yaml](cloud-init.yaml) with your top-level domain (domain.com)
4. Replace <%YOUR_DIGITALOCEAN_API_KEY%> with an API token. [Ref](https://cloud.digitalocean.com/settings/api/tokens)
When creating the server, you'll need to use an Ubuntu 16.x image with at least 1GB Memory.


## Deploy Plan:
By pasting [cloud-init.yaml](cloud-init.yaml) into user-data section of server create page, server will automatically:
1. Install and start [nginx](https://www.digitalocean.com/community/tags/nginx)
2. Update DigitalOcean DNS to point a subdomain [this_server_name].[your_top_level_domain.com]
 at public IPV4 of this server.
3. Install and run [Let's Encrypt](https://www.digitalocean.com/community/tags/let-s-encrypt) certbot tool to automatically generate and renew SSL
 certificates (allowing magento to run only via HTTPS)
4. Add the jenkins debian package to source list, install and start jenkins.
5. Download the latest version of the [DigitalOcean Jenkins plugin](https://github.com/jenkinsci/digitalocean-plugin)

Install takes ~4 minutes, once server is created you can SSH in and follow progress by running `tail -f /var/log/cloud-init-output.log`. Once install is finished, server will reboot and you can go to https://[droplet-name].[your-domain.com] and finish the jenkins configuration. You will need the jenkins install password saved at `/var/lib/jenkins/secrets/initialAdminPassword`


## Further Reading:
This script builds on detailed instructions provided in the following tutorials:
- [Install and configure nginx as reverse proxy for jenkins](https://www.digitalocean.com/community/tutorials/how-to-configure-nginx-with-ssl-as-a-reverse-proxy-for-jenkins)
- [Install Let's Encrypt (certbot) with nginx on ubuntu](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-16-04)
- [Using the DigitalOcean Jenkins Plugin](http://nemerosa.ghost.io/2016/05/05/saving-money-with-jenkins-digital-ocean-and-docker/)
