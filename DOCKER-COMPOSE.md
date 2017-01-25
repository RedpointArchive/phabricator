# Launch Phabricator with docker-compose command

Docker Compose configuration file supplied in this repository defines a Phabricator service and a MySQL service.

The MySQL service uses official MySQL Docker image mysql:5.7.14 and the Phabricator service uses image redpointgames/phabricator.


## Configure `PHABRICATOR_HOST`

Before you start, you should modify the `PHABRICATOR_HOST` inside docker-compose.yml so that `PHABRICATOR_HOST` represents the real domain name you want to use.

If you do not modify the `PHABRICATOR_HOST`, Phabricator will not function correctly.

## Docker Volume

By default, it tries to mount host directory /srv/docker/phabricator/mysql as /var/lib/mysql in MySQL service container and host directory /srv/docker/phabricator/repos as /repo in Phabricator service container.

It mounts host directory /srv/docker/phabricator/extensions as /srv/phabricator/phabricator/src/extensions in Phabricator service.

If you would like to add additional translations for phabricator, you can just drop php files in host directory /srv/docker/phabricator/extensions.

To ensure that MySQL database and code repositories are both persistent, please make sure the following directories exist in your docker host.

```bash
/srv/docker/phabricator/repos
/srv/docker/phabricator/mysql
```

The following directory is optional and can be absent in your docker host.

```bash
/srv/docker/phabricator/extensions
```

It is required if you need extra Phabricator translations.

## Launch Phabricator

Once you configure `PHABRICATOR_HOST` and Docker Volume, you can run the following command within the directory where docker-compose.yml resides.

To launch Phabricator in daemon mode

```bash
docker-compose up -d
```

To launch Phabricator in interactive mode

```bash
docker-compose up
```