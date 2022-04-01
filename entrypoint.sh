#!/bin/sh
set -e

# If the script has any arguments, invoke the CLI instead.
# This allows for "docker run skayo/trash-updater create-config", "docker run skayo/trash-updater --help", etc.
if [ "$#" -gt 0 ]
then
    trash "$@"
else
	echo "Starting cron daemon..."
    /usr/sbin/crond -f -c /var/spool/cron/crontabs
fi
