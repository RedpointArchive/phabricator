# Phabricator

This is a Docker image which provides a fully configured Phabricator image, including SSH connectivity to repositories, real-time notifications via Web Sockets and all of the other parts that are normally difficult to configure done for you.

You'll need an instance of MySQL for this Docker image to connect to, and for basic setups you can specify it with either the `MYSQL_LINKED_CONTAINER` or `MYSQL_HOST` environment variables, depending on where your instance of MySQL is.

## License

The configuration scripts provided in this image are licensed under the MIT license.  Phabricator itself and all accompanying software are licensed under their respective software licenses.

## Configuration

For basic configuration in getting the image running, refer to [Basic Configuration](BASIC_CONFIG.md).

For more advanced configuration topics including:

* Using different source repositories (for patched versions of Phabricator)
* Running custom commands during the boot process, and
* Baking configuration into your own derived Docker image

refer to [Advanced Configuration](ADVANCED-CONFIG.md).

