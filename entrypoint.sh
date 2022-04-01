#!/bin/sh
set -e

# If the script has any arguments, invoke the CLI instead.
# This allows for "docker run skayo/trash-updater create-config", "docker run skayo/trash-updater --help", etc.
if [ "$#" -gt 0 ]
then
    /usr/local/bin/trash "$@"
else
	echo "Creating crontab file..."
	echo "${CRON_SCHEDULE:-@daily} /usr/local/bin/trash sonarr --config ${CONFIG_FILE:-/config/trash.yml}" > /var/spool/cron/crontabs/root
    echo "${CRON_SCHEDULE:-@daily} /usr/local/bin/trash radarr --config ${CONFIG_FILE:-/config/trash.yml}" >> /var/spool/cron/crontabs/root

	echo "Starting cron daemon..."
    exec crond -f
fi
