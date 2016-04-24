# Basic Configuration

For most basic setups, you can use environment variables to configure the Phabricator image to your liking.  This works well with tools like `docker-compose`.

## Full Environment Variable Reference

- `PHABRICATOR_HOST` - The base URI for the Phabricator host (e.g. "https://mydomain.com").
- `MYSQL_LINKED_CONTAINER` - Use this if you want to connect to a MySQL container (see below).
- `MYSQL_HOST` - Use this if you want to connect to an external MySQL host (see below).
- `MYSQL_PORT` - When connecting to an external MySQL host, use this port (optional).
- `MYSQL_USER` - The user to connect to MySQL as.
- `MYSQL_PASS` - The password to connect to MySQL.
- `MYSQL_STORAGE_NAMESPACE` - The prefix to use for database names (optional, defaults to "phabricator").
- `ENABLE_APCU` - Enable the APCu extension for PHP.  This may improve performance, but is not as stable as regular PHP.
- `ENABLE_UPDATE_ON_START` - By default this image uses the version of Phabricator baked into the image when it was made.  By setting this to "true", it will fetch the latest version of Phabricator when the image starts.
- `SSL_TYPE` - One of "none", "manual" or "letsencrypt".  See below for configuration (defaults to "none").
- `SSL_CERTIFICATE` - The path to the SSL certificate chain (manual mode only).
- `SSL_PRIVATE_KEY` - The path to the SSL private key (manual mode only).
- `SSL_EMAIL` - The email address to use when registering for an SSL certificate (Let's Encrypt mode only)

The following options automatically turn on `ENABLE_UPDATE_ON_START`:

- `OVERRIDE_PHABRICATOR_URI` - Changes the Git URI to clone Phabricator from.
- `OVERRIDE_PHABRICATOR_BRANCH` - Changes the Git branch or commit to use for the Phabricator repository.
- `OVERRIDE_ARCANIST_URI` - Changes the Git URI to clone Arcanist from.
- `OVERRIDE_ARCANIST_BRANCH` - Changes the Git branch or commit to use for the Arcanist repository.
- `OVERRIDE_LIBPHUTIL_URI` - Changes the Git URI to clone libphutil from.
- `OVERRIDE_LIBPHUTIL_BRANCH` - Changes the Git branch or commit to use for the libphutil repository.

# Configuring MySQL

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

# Configuring Phabricator

Phabricator needs some basic information about how clients will connect to it.  You can provide the base URI for Phabricator with the `PHABRICATOR_URI` environment variable, like so:

```
docker run ... --env PHABRICATOR_URI=myphabricator.com ...
```

# Configuring SSL

You can configure SSL in one of three ways: you can omit it entirely, you can turn on the automatic Let's Encrypt registration or you can provide SSL certificates.

## No SSL

This is the default.  If you provide no SSL related options, this image doesn't serve anything on port 443 (HTTPS).

## Automatic SSL via Let's Encrypt

For this to work, you need to provide a volume mapped to `/config`, so that the image can store certificates across restarts.  You also need to set `PHABRICATOR_URI` as documented above.

To enable automated SSL via Let's Encrypt, provide the following environment variables:

```
docker run ... --env SSL_TYPE=letsencrypt --env SSL_EMAIL='youremail@domain.com' --env PHABRICATOR_URI=myphabricator.com -v /some/host/path:/config ...
```

## Manual SSL

If you want to provide your own certificates, map a volume containing your certificates and set the appropriate environment variables:

```
docker run ... --env SSL_TYPE=manual --env SSL_CERTIFICATE=/ssl/cert.pem --env SSL_PRIVATE_KEY=/ssl/cert.key -v /host/folder/containing/certs:/ssl ...
```

