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

    /usr/bin/docker run -p 22:22 -p 843:843 -p 22280:22280 -v /path/to/config:/config -v /path/to/repo/storage:/srv/repo --name=phabricator --link mariadb:linked_mariadb hachque/phabricator

What do these parameters do?

    -p 22:22 = forward the host's SSH port to Phabricator for repository access
    -p 843:843 = forward the host's 843 port for the notification server
    -p 22280:22280 = forward the host's 22280 port for the notification server
    -v path/to/config:/config = map the configuration from the host to the container
    -v path/to/repo/storage:/srv/repo = map the repository storage from the host to the container
    --name phabricator = the name of the container
    --link mariadb:linked_mariadb = (optional) if you are running MariaDB in a Docker container
    hachque/phabricator = the name of the image

This assumes that you are using a reverse proxy container (such as `hachque/nginx-autoproxy`) to route HTTP and HTTPS requests to the Phabricator container.  If you are not, and you want to just expose the host's HTTP and HTTPS ports to Phabricator directly, you can add the following options:

    -p 80:80 -p 443:443

This image is intended to be used in such a way that a new container is created each time it is started, instead of starting and stopping a pre-existing container from this image.  You should configure your service startup so that the container is stopped and removed each time.  A systemd configuration file may look like:

    [Unit]
    Description=phabricator
    Requires=docker.service mariadb.service
     
    [Service]
    ExecStart=<command to start instance, see above>
    ExecStop=/usr/bin/docker stop phabricator
    ExecStop=/usr/bin/docker rm phabricator
    Restart=always
    RestartSec=5s
    
    [Install]
    WantedBy=multi-user.target

Because the container will be thrown away on each start, it's important to remember:

  - **Make sure you configure Phabricator to store files in MySQL or AWS**.  Don't use local file storage, or you'll lose the lot when the container exits.
  - **Map a directory from the host for repository storage**.  If you don't map a directory from the host for repository storage, then all your repositories will be lost when the container exists.

Enabling SSL
----------------

To enable SSL, place `cert.pem` and `cert.key` files alongside `script.pre`.  The Docker
container will automatically detect the presence of the certificates and configure
Nginx to run with SSL enabled.

Linking to a DB container
---------------------------

If you are running MariaDB in a Docker container (e.g. using the `hachque/mariadb` container), you can configure the `script.pre` file like so to use the linked MariaDB container:

    ./bin/config set mysql.host "$LINKED_MARIADB_PORT_3306_TCP_ADDR"
    ./bin/config set mysql.port "$LINKED_MARIADB_PORT_3306_TCP_PORT"
    
Include the `--link` option as shown above to link the Phabricator container to the MariaDB container.

SSH / Login
--------------

**Username:** root

**Password:** linux

**Port:** 24

(Note that repository hosting for Phabricator is served on port 22)

