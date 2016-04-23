# Phabricator

This is a Docker image which provides a fully configured Phabricator image, including SSH connectivity to repositories, real-time notifications via Web Sockets and all of the other parts that are normally difficult to configure done for you.

You'll need an instance of MySQL for this Docker image to connect to, and for basic setups you can specify it with either the `MYSQL_LINKED_CONTAINER` or `MYSQL_HOST` environment variables, depending on where your instance of MySQL is.

## License

The configuration scripts provided in this image are licensed under the MIT license.  Phabricator itself and all accompanying software are licensed under their respective software licenses.

## Basic Configuration

For most basic setups, you can use environment variables to configure the Phabricator image to your liking.  This works well with tools like `docker-compose`.

### Configuring MySQL

You need to do this before running the container, or things won't work.  If you have MySQL running in another container, you can use `MYSQL_LINKED_CONTAINER`, like so:

```
docker run --rm --env MYSQL_LINKED_CONTAINER=MYSQL --env MYSQL_USER=phabricator --env MYSQL_PASS=password --link somecontainer:mysql -p 80:80 -p 443:443 -p 22:22 hachque/phabricator
```

Note that the environment variable's value is equal to the linked container's name once converted to the variable format; that is a linked container name of `my.sql.container` would become `MY_SQL_CONTAINER`.

If your instance of MySQL is running on the host or some external system, you can connect to it using the `MYSQL_USER` and associated variables like so:

```
docker run --rm --env MYSQL_HOST=externalhost.com --env MYSQL_PORT=3306 --env MYSQL_USER=phabricator --env MYSQL_PASS=password -p 80:80 -p 443:443 -p 22:22 hachque/phabricator
```

The `MYSQL_PORT` environment variable is set to a sensible default, so normally you don't need to explicitly provide it.

### Configuring Phabricator

Phabricator needs some basic information about how clients will connect to it.  You can provide the base URI for Phabricator with the `PHABRICATOR_URI` environment variable, like so:

```
docker run ... --env PHABRICATOR_URI=myphabricator.com ...
```

### Configuring SSL

You can configure SSL in one of three ways: you can omit it entirely, you can turn on the automatic Let's Encrypt registration or you can provide SSL certificates.

#### No SSL

This is the default.  If you provide no SSL related options, this image doesn't serve anything on port 443 (HTTPS).

#### Automatic SSL via Let's Encrypt

For this to work, you need to provide a volume mapped to `/config`, so that the image can store certificates across restarts.  You also need to set `PHABRICATOR_URI` as documented above.

To enable automated SSL via Let's Encrypt, provide the following environment variables:

```
docker run ... --env SSL_TYPE=letsencrypt --env SSL_EMAIL='youremail@domain.com' --env PHABRICATOR_URI=myphabricator.com -v /some/host/path:/config ...
```

#### Manual SSL

If you want to provide your own certificates, map a volume containing your certificates and set the appropriate environment variables:

```
docker run ... --env SSL_TYPE=manual --env SSL_CERTIFICATE=/ssl/cert.pem --env SSL_PRIVATE_KEY=/ssl/cert.key -v /host/folder/containing/certs:/ssl ...
```

## Advanced Configuration

Advanced configuration topics including:

* Using different source repositories (for patched versions of Phabricator)
* Running custom commands during the boot process, and
* Baking configuration into your own derived Docker image

can be found on the GitHub wiki.

