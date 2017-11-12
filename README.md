# Phabricator

This is a Docker image which provides a fully configured Phabricator image, including SSH connectivity to repositories, real-time notifications via Web Sockets and all of the other parts that are normally difficult to configure done for you.

You'll need an instance of MySQL for this Docker image to connect to, and for basic setups you can specify it with either the `MYSQL_LINKED_CONTAINER` or `MYSQL_HOST` environment variables, depending on where your instance of MySQL is.

The most basic command to run Phabricator is:

```
docker run \
    --rm -p 80:80 -p 443:443 -p 22:22 \
    --env PHABRICATOR_HOST=mydomain.com \
    --env MYSQL_HOST=10.0.0.1 \
    --env MYSQL_USER=user \
    --env MYSQL_PASS=pass \
    --env PHABRICATOR_REPOSITORY_PATH=/repos \
    -v /host/repo/path:/repos \
    redpointgames/phabricator
```

Alternatively you can launch this image with Docker Compose. Refer to [Using Docker Compose](https://github.com/RedpointGames/phabricator/blob/master/DOCKER-COMPOSE.md) for more information.

**NOTICE:** This repository has been recently moved to `RedpointGames/phabricator` and the Docker image to use is now `redpointgames/phabricator`.  `hachque/phabricator` will be kept in sync with `redpointgames/phabricator` for the foreseeable future, so you don't need to update your configuration immediately.

## Configuration

For basic configuration in getting the image running, refer to [Basic Configuration](https://github.com/RedpointGames/phabricator/blob/master/BASIC-CONFIG.md).

For more advanced configuration topics including:

* Using different source repositories (for patched versions of Phabricator)
* Running custom commands during the boot process, and
* Baking configuration into your own derived Docker image

refer to [Advanced Configuration](https://github.com/RedpointGames/phabricator/blob/master/ADVANCED-CONFIG.md).

For users that are upgrading to this version and currently using the old `/config` mechanism to configure Phabricator, this configuration mechanism will continue to work, but it's recommended that you migrate to environment variables or baked images when you next get the chance.

## Support

For issues regarding environment setup, missing tools or parts of the image not starting correctly, file a GitHub issue.

For issues encountered while using Phabricator itself, report the issue with reproduction steps on the [upstream bug tracker](https://secure.phabricator.com/book/phabcontrib/article/bug_reports/).

## License

The configuration scripts provided in this image are licensed under the MIT license.  Phabricator itself and all accompanying software are licensed under their respective software licenses.
