DigitalOcean User Scripts Library
=================================

This repository contains a collection of scripts that can be used to help provision
your Droplet on first boot. When creating a new Droplet, they can be provided as
"user data."

![DigitalOcean Control Panel](https://assets.digitalocean.com/articles/metadata/user-data.png)

For an introduction for the technologies involved, check out these articles from
[the DigitalOcean Community](https://www.digitalocean.com/community/) as well as
the [upstream cloud-init documentation](https://cloudinit.readthedocs.org/en/latest/):

* [An Introduction to Droplet Metadata](https://www.digitalocean.com/community/tutorials/an-introduction-to-droplet-metadata)
* [An Introduction to Cloud-Config Scripting](https://www.digitalocean.com/community/tutorials/an-introduction-to-cloud-config-scripting)
* [How To Use Cloud-Config For Your Initial Server Setup](https://www.digitalocean.com/community/tutorials/how-to-use-cloud-config-for-your-initial-server-setup)


Contributing
------------

Scripts in this repository can be in one of two formats, shell scripts and
cloud-config files. In order to encourage simplicity and readability, it is
highly encouraged to use the declarative cloud-config file format when possible.

Each directory must contain a README.md file describing the scripts contained
within it, including the target platform and a description of any needed user
input. As these scripts are not interactive, please use the standardized
format of **`<%DESCRIPTIVE_NAME%>`** for variables that should be provided by
the user before running the script. (See the `examples/` directory.)

Feedback
--------

This project is an experiment, and it won't be successful without your feedback.
Let us know what you think by [opening an issue here on GitHub](https://github.com/digitalocean/do_user_scripts/issues).
