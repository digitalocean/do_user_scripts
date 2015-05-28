Examples
========

Scripts in this directory are examples of the style used in this repository.

new_user.yml
------------

This cloud-config file creates an new *passwordless* sudo user on the Droplet
and adds the specified SSH public key to the account.

**Required input**:

* `<%USERNAME%>` - The name for the new user account.
* `<%SSH_PUB_KEY%>` - The SSH public key, in the format:

```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDf0q4PyG0doiBQYV7OlOxbRjle026hJPBWD+eKHWuVXIpAiQlSElEBqQn0pOqNJZ3IBCvSLnrdZTUph4czNC4885AArS9NkyM7lK27Oo8RV888jWc8hsx4CD2uNfkuHL+NI5xPB/QT3Um2Zi7GRkIwIgNPN5uqUtXvjgA+i1CS0Ku4ld8vndXvr504jV9BMQoZrXEST3YlriOb8Wf7hYqphVMpF3b+8df96Pxsj0+iZqayS9wFcL8ITPApHi0yVwS8TjxEtI3FDpCbf7Y/DmTGOv49+AWBkFhS2ZwwGTX65L61PDlTSAzL+rPFmHaQBHnsli8U9N6E4XHDEOjbSMRX user@example.com
```

nginx.sh
--------

This bash script installs Nginx and demonstrates using the DigitalOcean
metadata service to find the `hostname` and IP address of the droplet. As it
expects to find the default Nginx configuration at `/etc/nginx/sites-available/default`,
it only targets Ubuntu and Debian.

**Target**: Ubuntu, Debian