#
# Auto-generated from tmpl.Dockerfile
#

FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine AS build
WORKDIR /build

# Build binary
RUN set -ex; \
	git clone -b "${VERSION}" https://github.com/rcdailey/trash-updater.git ./; \
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


FROM mcr.microsoft.com/dotnet/runtime-deps:7.0-alpine@sha256:c90872d8ad31e056b942966f9f47cc071369f2b04c726b7910d45cb375e6150d

# Copy built binary
COPY --from=build /build/output/trash /usr/local/bin/trash

