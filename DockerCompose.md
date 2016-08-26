# Launch Phabricator with docker-compose command

## Configure `PHABRICATOR_HOST` and Launch Phabricator

Docker Compose configuration file supplied in this repository defines a Phabricator service named "phabricator" and a MySQL service named "mysql".

Before you start, you should modify the `PHABRICATOR_HOST` inside docker-compose.yml so that `PHABRICATOR_HOST` represents the real domain name you want to use.

Once you configure `PHABRICATOR_HOST`, you can run the following command within the directory where docker-compose.yml resides.

To launch Phabricator in daemon mode

'''
docker-compose up -d
'''

To launch Phabricator in interactive mode

'''
docker-compose up
'''

## Docker Volume

By default, it tries to mount host directory /srv/docker/phabricator/mysql as /var/lib/mysql in "mysql" service container and host directory /srv/docker/phabricator/repos as /repo in "phabricator" service container.

Also, it mounts host directory /srv/docker/phabricator/extensions as /srv/phabricator/phabricator/src/extensions in phabricator service.

If you would like to add additional translations for phabricator, you can just drop php files in host directory /srv/docker/phabricator/extensions.
