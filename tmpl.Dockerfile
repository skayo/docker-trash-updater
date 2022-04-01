FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:6.0-alpine@sha256:4882761845f96b050a4d77e1b3d01f11269c8b1499f75889b63eafa2dbb54064 AS build
WORKDIR /build

# Get source code
RUN set -ex; \
	git clone -b "${VERSION}" https://github.com/rcdailey/trash-updater.git /build

# Build binary
ARG TARGETPLATFORM
RUN case "$TARGETPLATFORM" in \
		"linux/arm/v7") runtime='alpine-arm' ;; \
		"linux/arm64") runtime='alpine-arm64' ;; \
		"linux/amd64") runtime='alpine-x64' ;; \
		*) echo >&2 "ERROR: Unsupported target platform: $TARGETPLATFORM"; exit 1 ;; \
	esac; \
	dotnet publish src/Trash \
		--output ./output  \
		--runtime $runtime \
		--self-contained true \
		--configuration Release


FROM mcr.microsoft.com/dotnet/runtime-deps:6.0-alpine@sha256:91db5cb22c9114ae9b7f96413931b38eed665e5c5963a7670c1323c64a201ce9

# Runtime configuration options
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
ENV DOTNET_RUNNING_IN_CONTAINER=true

# Copy built binary from build step
COPY --from=build /build/output/trash /usr/local/bin/trash

# Remove the existing crontab file (will be created dynamically by entrypoint.sh)
RUN set -ex; \
    rm -r /var/spool/cron/crontabs/root; \
    rm -rf /etc/periodic

# Define entrypoint (script that starts the cron job daemon or the CLI, depending on the arguments)
COPY --chmod=0755 ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
