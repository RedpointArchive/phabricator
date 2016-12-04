# Basic Configuration

For most basic setups, you can use environment variables to configure the Phabricator image to your liking.  This works well with tools like `docker-compose`.

A full list of all available environment variables can be found in the [Full Environment Variable List](ENV-LIST.md).

# Configuring MySQL

You need to do this before running the container, or things won't work.  If you have MySQL running in another container, you can use `MYSQL_HOST`, like so:

```
docker run ... \
    --env MYSQL_HOST=mysql \
    --env MYSQL_USER=phabricator \
    --env MYSQL_PASS=password \
    --link somecontainer:mysql \
    ...
```

If your instance of MySQL is running on the host or some external system, you can connect to it using the `MYSQL_USER` and associated variables like so:

```
docker run \
    --env MYSQL_HOST=externalhost.com \
    --env MYSQL_PORT=3306 \
    --env MYSQL_USER=phabricator \
    --env MYSQL_PASS=password \
    ...
```

The `MYSQL_PORT` environment variable is set to a sensible default, so normally you don't need to explicitly provide it.

# Configuring Phabricator

Phabricator needs some basic information about how clients will connect to it.  You can provide the base URI for Phabricator with the `PHABRICATOR_HOST` environment variable, like so:

```
docker run ... \
    --env PHABRICATOR_HOST=myphabricator.com \
    ...
```

It's recommended that you specify an alternate domain to serve files and other user content from.  This will make Phabricator more secure.  You can configure this using the `PHABRICATOR_CDN` option, like so:

```
docker run ... \
    --env PHABRICATOR_CDN=altdomain.com \
    ...
```

When using the Let's Encrypt SSL configuration, it will automatically register both domains.

You also need to configure a place to store repository data.  This should be a volume mapped from the host, for example:

```
docker run ... \
    --env PHABRICATOR_REPOSITORY_PATH=/repos \
    -v /path/on/host:/repos \
    ...
```

To provide SSH access to repositories, you need to set a path to store the SSH host keys in.  If you are not baking a derived image (see [Advanced Configuration](ADVANCED-CONFIG.md)), then you need to map that path to a location on the host.  If you are baking an image, you can omit the mapping and the SSH keys will form part of your derived image.  You can configure SSH access to repositories like so:

```
docker run ... \
    --env PHABRICATOR_HOST_KEYS_PATH=/hostkeys/persisted \
    -v /path/on/host:/hostkeys \
    ...
```

By default, Phabricator stores file data in MySQL.  You can change this with the `PHABRICATOR_STORAGE_TYPE` option, which can be either `mysql` (the default), `disk` or `s3`.

You can configure Phabricator to store files on disk by selecting the `disk` option, mapping a volume and configuring the path:

```
docker run ... \
    --env PHABRICATOR_STORAGE_TYPE=disk \
    --env PHABRICATOR_STORAGE_PATH=/files \
    -v /path/on/host:/files \
    ...
```

Alternatively if you want to store file data in S3, you can do so by selecting the `s3` option, configuring the bucket and setting the AWS access and secret keys to use:

```
docker run ... \
    --env PHABRICATOR_STORAGE_TYPE=s3 \
    --env PHABRICATOR_STORAGE_BUCKET=mybucket \
    --env AWS_S3_ACCESS_KEY=... \
    --env AWS_S3_SECRET_KEY=... \
    ...
```

# Configuring SSL

You can configure SSL in one of three ways: you can omit it entirely, you can turn on the automatic Let's Encrypt registration or you can provide SSL certificates.

## No SSL

This is the default.  If you provide no SSL related options, this image doesn't serve anything on port 443 (HTTPS).

## Load Balancer terminated SSL

If your load balancer is terminating SSL, you should set `SSL_TYPE` to `external` so that Phabricator will render out all links as HTTPS.  Without doing this (i.e. if you left the default of `none`), all of the Phabricator URLs would be prefixed with `http://` instead of `https://`.

**NOTE:** If you use Load Balancer terminated SSL, things like real-time notifications are unlikely to work correctly.  It's recommended that you let the Docker instance terminate the SSL connection, and use TCP forwarding in any load balancer configuration you might have set up.

```
docker run ... \
    --env SSL_TYPE=external \
    ...
```

## Automatic SSL via Let's Encrypt

For this to work, you need to provide a volume mapped to `/config`, so that the image can store certificates across restarts.  You also need to set `PHABRICATOR_HOST` and optionally `PHABRICATOR_CDN` as documented above.

To enable automated SSL via Let's Encrypt, provide the following environment variables:

```
docker run ... \
    --env SSL_TYPE=letsencrypt \
    --env SSL_EMAIL='youremail@domain.com' \
    --env PHABRICATOR_HOST=myphabricator.com \
    --env PHABRICATOR_CDN=altdomain.com \
    -v /some/host/path:/config \
    ...
```

## Manual SSL

If you want to provide your own certificates, map a volume containing your certificates and set the appropriate environment variables:

```
docker run ... \
    --env SSL_TYPE=manual \
    --env SSL_CERTIFICATE=/ssl/cert.pem \
    --env SSL_PRIVATE_KEY=/ssl/cert.key \
    -v /host/folder/containing/certs:/ssl \
    ...
```
