Usage
----------

To configure this image, create a `config` directory, with a `script.pre` file inside it.  This
file should be marked as executable.  Place the following content in that file:

    #!/bin/bash

    # Set the name of the host running MySQL:
    ./bin/config set mysql.host "example.com"

    # If MySQL is running on a non-standard port:
    #./bin/config set mysql.port 3306

    # Set the username for connecting to MySQL:
    ./bin/config set mysql.user "root"

    # Set the password for connecting to MySQL:
    ./bin/config set mysql.pass "password"

    # Set the base URI that will be used to access Phabricator:
    ./bin/config set phabricator.base-uri "http://myphabricator.com/"

To run this image:

    docker run --rm -P -v path/to/config:/config hachque/phabricator

What do these parameters do?

    --rm = delete the container when it stops running
    -P = map exposed ports over NAT
    -v path/to/config:/config = map the configuration from the host to the container
    hachque/systemd-none = the name of the image

This image is intended to be used in such a way that a new container is created each time, instead of starting and stopping a pre-existing container from this image.  The use of `--rm` will cause all changes stored inside the container to be lost on exit, so remember:

  - **Make sure you configure Phabricator to store files in MySQL or AWS**.  Don't use local file storage, or you'll lose the lot when the container exits.
  - **Map a directory from the host for repository storage**.  If you don't map a directory from the host for repository storage, then all your repositories will be lost when the container exists.

Enabling SSL
----------------

To enable SSL, place `cert.pem` and `cert.key` files alongside `script.pre`.  The Docker
container will automatically detect the presence of the certificates and configure
Nginx to run with SSL enabled.

SSH / Login
--------------

**Username:** root

**Password:** linux

