NoSQL
=====

Scripts in this folder install and configure common [NoSql databases](https://www.digitalocean.com/community/tutorials/a-comparison-of-nosql-database-management-systems-and-models).

mongodb.yml
---------------

Installs the latest MongoDB release from their offical repositories.


redis.yml
---------------

Installs the latest Redis from source. By default, it is bound to localhost and listens on port 6379. An init script is installed to `/etc/init.d/redis_6379`.