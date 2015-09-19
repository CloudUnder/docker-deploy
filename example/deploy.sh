#!/bin/bash

REMOTE="username@remotehostname"
BASEDIR="/var/www/lumen"

## Sync files to remote host, excluding files as defined in rsync-exclude
rsync -avz --delete --exclude-from=/custom/rsync-exclude /code/ ${REMOTE}:${BASEDIR}/
