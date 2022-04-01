#!/bin/sh
set -e

# If the script has any arguments, invoke the CLI instead.
# This allows for "docker run skayo/trash-updater create-config", "docker run skayo/trash-updater --help", etc.
if [ "$#" -gt 0 ]; then
	/usr/local/bin/trash "$@"
else
	echo "Creating crontab file..."
	schedule=${CRON_SCHEDULE:-@daily}
	sonarr_schedule=${CRON_SCHEDULE_SONARR:-$schedule}
	radarr_schedule=${CRON_SCHEDULE_RADARR:-$schedule}
	config_file=${CONFIG_FILE:-/config/trash.yml}
	echo "$sonarr_schedule /usr/local/bin/trash sonarr --config $config_file" > /var/spool/cron/crontabs/root
	echo "$radarr_schedule /usr/local/bin/trash radarr --config $config_file" >> /var/spool/cron/crontabs/root

	echo "Starting cron daemon..."
	exec crond -f
fi
