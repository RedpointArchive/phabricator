# Full Environment Variable Reference

- `PHABRICATOR_HOST` - The domain name for the Phabricator host (e.g. "mydomain.com").
- `PHABRICATOR_CDN` - The domain name to use for serving files and other user content (optional, but recommended).
- `PHABRICATOR_REPOSITORY_PATH` - The path to store repository data in.  This directory should be a volume mapped from the host, otherwise repository data will be lost when the container is destroyed.
- `PHABRICATOR_STORAGE_TYPE` - The type of storage to use for files.  Defaults to `mysql`, but you can set it to `disk` or `s3` for alterate storage options (see [Basic Configuration](BASIC-CONFIG.md)).
- `PHABRICATOR_STORAGE_PATH` - When using the `disk` type of storage, specifies the path in the container that's been mapped to the host for permanent file storage.  This should be a different path to `PHABRICATOR_REPOSITORY_PATH`.
- `PHABRICATOR_STORAGE_BUCKET` - When using the `s3` type of storage, specifies the bucket to store files in.
- `PHABRICATOR_VCS_USER` - The user name for SSH access. Defaults to `git`.
- `PHABRICATOR_VCS_PORT` - The Docker-exposed port used for SSH access. Sets `diffusion.ssh-port`, which affects the URI displayed in Diffusion.
- `PHABRICATOR_HOST_KEYS_PATH` - The path to store SSH host keys in.  This directory should be a volume mapped from the host, otherwise clients will be unable to connect after the container is restarted.
- `AWS_S3_ACCESS_KEY` - The AWS access key to use for S3.  Only needed when the `s3` storage type is selected.
- `AWS_S3_SECRET_KEY` - The AWS secret key to use for S3.  Only needed when the `s3` storage type is selected.
- `AWS_S3_REGION` - The AWS region to use for S3.  Only needed when the `s3` storage type is selected. Used in combination with `AWS_S3_REGION`. See [AWS Docs](https://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region).
- `AWS_S3_ENDPOINT` - The AWS endpoint to use for S3.  Only needed when the `s3` storage type is selected. Used in combination with `AWS_S3_ENDPOINT`. See [AWS Docs](https://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region).
- `MYSQL_HOST` - Use this if you want to connect to an external MySQL host (see [Basic Configuration](BASIC-CONFIG.md)).
- `MYSQL_PORT` - When connecting to an external MySQL host, use this port (optional).
- `MYSQL_USER` - The user to connect to MySQL as.
- `MYSQL_PASS` - The password to connect to MySQL.
- `MYSQL_STORAGE_NAMESPACE` - The prefix to use for database names (optional, defaults to "phabricator").
- `ENABLE_APCU` - Enable the APCu extension for PHP.  This may improve performance, but is not as stable as regular PHP.
- `ENABLE_UPDATE_ON_START` - By default this image uses the version of Phabricator baked into the image when it was made.  By setting this to "true", it will fetch the latest version of Phabricator when the image starts.
- `SSL_TYPE` - One of "none", "manual", "external" or "letsencrypt".  See [Basic Configuration](BASIC-CONFIG.md) for more information (defaults to "none").
- `SSL_CERTIFICATE` - The path to the SSL certificate chain (manual mode only).
- `SSL_PRIVATE_KEY` - The path to the SSL private key (manual mode only).
- `SSL_EMAIL` - The email address to use when registering for an SSL certificate (Let's Encrypt mode only)
- `SSL_DOMAINS` - An optional comma seperated list of the domains to issue for, in addition to `PHABRICATOR_HOST` (Let's Encrypt mode only)
- `DISABLE_IOMONITOR` - Disable the I/O monitor, which warns if the image is spending a lot of CPU time waiting on disk I/O.

The following advanced options automatically turn on `ENABLE_UPDATE_ON_START`:

- `OVERRIDE_PHABRICATOR_URI` - Changes the Git URI to clone Phabricator from.
- `OVERRIDE_PHABRICATOR_BRANCH` - Changes the Git branch or commit to use for the Phabricator repository.
- `OVERRIDE_ARCANIST_URI` - Changes the Git URI to clone Arcanist from.
- `OVERRIDE_ARCANIST_BRANCH` - Changes the Git branch or commit to use for the Arcanist repository.
- `OVERRIDE_LIBPHUTIL_URI` - Changes the Git URI to clone libphutil from.
- `OVERRIDE_LIBPHUTIL_BRANCH` - Changes the Git branch or commit to use for the libphutil repository.

The following advanced options allow you to run custom scripts during stages of the boot process:

- `SCRIPT_BEFORE_UPDATE` - Occurs before everything else, including before Phabricator and it's associated repositories are updated.
- `SCRIPT_BEFORE_MIGRATION` - Occurs after Phabricator is updated, but before the database migration scripts are run.  You can use this to clone additional libphutil libraries next to Phabricator, and you can use this to modify MySQL connection information.
- `SCRIPT_AFTER_MIGRATION` - Occurs after database scripts have been run.
- `SCRIPT_AFTER_LETS_ENCRYPT` - Occurs after Let's Encrypt has registered domains.  You can use this script to register additional domains that aren't specified by `PHABRICATOR_HOST` or `PHABRICATOR_CDN`.  This only runs if SSL is set to the Let's Encrypt mode.
- `SCRIPT_BEFORE_DAEMONS` - Occurs before background daemons are launched.
- `SCRIPT_AFTER_DAEMONS` - Occurs after background daemons are launched.  You can use this to launch additional daemons.

