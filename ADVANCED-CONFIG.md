# Advanced Configuration

If you want to perform any of the following customizations to Phabricator:

* Using different source repositories (for patched versions of Phabricator)
* Running custom commands during the boot process, and
* Baking configuration into your own derived Docker image

then this is the guide to read.

# Using different source repositories

If you have a custom version of Phabricator with patches, you can change the Git URLs and branches that the image uses with the following environment variables:

- `OVERRIDE_PHABRICATOR_URI` - Changes the Git URI to clone Phabricator from.
- `OVERRIDE_PHABRICATOR_BRANCH` - Changes the Git branch or commit to use for the Phabricator repository.
- `OVERRIDE_ARCANIST_URI` - Changes the Git URI to clone Arcanist from.
- `OVERRIDE_ARCANIST_BRANCH` - Changes the Git branch or commit to use for the Arcanist repository.
- `OVERRIDE_LIBPHUTIL_URI` - Changes the Git URI to clone libphutil from.
- `OVERRIDE_LIBPHUTIL_BRANCH` - Changes the Git branch or commit to use for the libphutil repository.

For example:

```
docker run ... \
    --env OVERRIDE_PHABRICATOR_URI='https://github.com/mycompany/phabricator' \
    ...
```

# Running custom commands during the boot process

At various stages of the boot process, you can run custom scripts to insert additional configuration into how Phabricator is set up, such as adding external libraries.  You can use the following environment variables to point to custom scripts:

- `SCRIPT_BEFORE_UPDATE` - Occurs before everything else, including before Phabricator and it's associated repositories are updated.
- `SCRIPT_BEFORE_MIGRATION` - Occurs after Phabricator is updated, but before the database migration scripts are run.  You can use this to clone additional libphutil libraries next to Phabricator, and you can use this to modify MySQL connection information.
- `SCRIPT_AFTER_MIGRATION` - Occurs after database scripts have been run.
- `SCRIPT_AFTER_LETS_ENCRYPT` - Occurs after Let's Encrypt has registered domains.  You can use this script to register additional domains that aren't specified by `PHABRICATOR_HOST` or `PHABRICATOR_CDN`.  This only runs if SSL is set to the Let's Encrypt mode.
- `SCRIPT_BEFORE_DAEMONS` - Occurs before background daemons are launched.
- `SCRIPT_AFTER_DAEMONS` - Occurs after background daemons are launched.  You can use this to launch additional daemons.

For example, if you wanted to add an external libphutil library, you might configure the image like this:

```
docker run ... \
    --env SCRIPT_BEFORE_MIGRATION=/scripts/beforemig.sh \
    -v /hostscripts:/scripts \
    ...
```

Then inside `/hostscripts` on the host you'd have the following executable shell script:

```
#!/bin/bash

git clone https://github.com/mycompany/my-extension /srv/phabricator/my-extension
cd /srv/phabricator/phabricator
sudo -u "$PHABRICATOR_VCS_USER" ./bin/config set load-libraries '["/srv/phabricator/my-extension"]'
```

# Baking configuration into an image

You can bake the configuration and initial start-up of this image into your own derived image.  The benefits of doing this are:

* The start-up of the image will be faster, as the one-time processes will have already been done
* You can push this image to a private repository and use it to run a Phabricator cluster

To bake an image, create a `Dockerfile` like this:

```
FROM redpointgames/phabricator

ADD my-script /my-script
RUN /my-script
```

then create `my-script` like this:

```
#!/bin/bash
 
set -e
set -x

export MYSQL_HOST="..."
# .. export more configuration values here ..

/bake /my-script
```

You can set the advanced environment variables for hooking scripts as documented in [Full Environment Variable Reference](ENV-LIST.md), and add those
scripts to your image so they run each time.

When writing custom scripts for your image, you can check if the script is being run during the initial bake process by checking with:

```
if [ -f /is-baking ]; then
```

Likewise, you can check if you are not doing an initial bake (non-baked start up, or start up after bake), with:

```
if [ ! -f /is-baking ]; then
```

You can check if the script is running after the image has been baked with:

```
if [ -f /baked ]; then
```

Likewise, you can check if you are not running in a baked image (non-baked start up, or during initial bake), with:

```
if [ ! -f /baked ]; then
```