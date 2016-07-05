#!/bin/sh
#
# Swap File Creator
#
# This script will create and configure a swap file
# on your droplet at creation time.

# Swap file size
# example swapsize="1G"
swapsize="<%SWAP_FILE_SIZE%>"


fallocate -l $swapsize /swapfile;
chmod 600 /swapfile;
mkswap /swapfile;
swapon /swapfile;
 echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab;
