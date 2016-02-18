Admin Scripts
=============

postfix-send-only.yml
---------------------

Installs the Postfix SMTP server [configured in send-only mode](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-postfix-as-a-send-only-smtp-server-on-ubuntu-14-04).

**Optional input**:

* `<%EMAIL_ADDR%>` - Email address to send test message to when installation is complete.

swap.sh
-------

This script will create and activate a swap file at `/swapfile` on your new droplet in the size you specify.  An entry in `/etc/fstab` will also be made to automatically enable the swap file on boot.

**Required input**:

* `<%SWAP_FILE_SIZE%>` - The size of the swap file to create. E.g. "1G"

saltstack.bash
--------------

This script upgrades the system to the latest packages, installs salt-minion, and configures the master server. Please read the top of the file for more information.

**Required input**:

* `<%HOSTNAME%>` - The 'nice name' for your server. Not the FQDN.
* `<%MASTER%>` - The IP address for the salt master server. Either local or public will work.
