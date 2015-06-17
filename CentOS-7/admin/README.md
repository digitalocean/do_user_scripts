Admin Scripts
=============

swap.sh
-------

This script will create and activate a swap file at `/swapfile` on your new droplet in the size you specify.  An entry in `/etc/fstab` will also be made to automatically enable the swap file on boot.

**Required input**:

* `<%SWAP_FILE_SIZE%>` - The size of the swap file to create. E.g. "1G"