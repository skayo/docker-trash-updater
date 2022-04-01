#
# Auto-generated from tmpl.Dockerfile
#

FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine AS build
WORKDIR /build

# Build binary
RUN set -ex; \
	git clone -b v1.8.2 https://github.com/rcdailey/trash-updater.git ./; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		armhf) runtime='alpine-arm' ;; \
		aarch64) runtime='alpine-arm64' ;; \
		x86_64) runtime='alpine-x64' ;; \
		*) echo >&2 "error: unsupported architecture: $apkArch"; exit 1 ;; \
	esac; \
	dotnet publish src/Trash \
		--output ./output  \
		--runtime $runtime \
		--self-contained true \
		--configuration Release;


FROM mcr.microsoft.com/dotnet/runtime-deps:6.0-alpine

# Runtime configuration options
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
ENV DOTNET_RUNNING_IN_CONTAINER=true

# Copy built binary
COPY --from=build /build/output/trash /usr/local/bin/trash

# Install required packages
RUN apk add --no-cache tini

# Setup cron jobs
ARG SCHEDULE="@daily"
RUN echo "$SCHEDULE /usr/local/bin/trash sonarr --config /config/trash.yml" > /var/spool/cron/crontabs/root; \
    echo "$SCHEDULE /usr/local/bin/trash radarr --config /config/trash.yml" >> /var/spool/cron/crontabs/root;

# Start crontab daemon using tini
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/sbin/crond", "-f"]
