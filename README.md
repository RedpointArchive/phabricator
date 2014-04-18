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

    docker run -d -P -v path/to/config:/config hachque/phabricator

What do these parameters do?

    -d = detach from tty
    -P = map exposed ports over NAT
    -v path/to/config:/config = map the configuration from the host to the container
    hachque/systemd-none = the name of the image

You can use this image to run applications if you don't want to use cgroups or privileged mode.

Enabling SSL
----------------

To enable SSL, place `cert.pem` and `cert.key` files alongside `script.pre`.  The Docker
container will automatically detect the presence of the certificates and configure
Nginx to run with SSL enabled.

SSH / Login
--------------

**Username:** root

**Password:** linux

