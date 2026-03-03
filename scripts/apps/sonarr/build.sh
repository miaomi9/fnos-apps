#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
ZIP_ARCH="${ZIP_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building Sonarr ${VERSION} for ${ZIP_ARCH}"

case "$ZIP_ARCH" in
  amd64|x86_64)
    TARBALL_ARCH="x64"
    ;;
  arm64|aarch64)
    TARBALL_ARCH="arm64"
    ;;
  *)
    echo "Unsupported architecture: $ZIP_ARCH" >&2
    exit 1
    ;;
esac

ASSET_NAME="Sonarr.main.${VERSION}.linux-${TARBALL_ARCH}.tar.gz"
DOWNLOAD_URL="https://github.com/Sonarr/Sonarr/releases/download/v${VERSION}/${ASSET_NAME}"
echo "Downloading: $DOWNLOAD_URL"
curl -fL -o sonarr.tar.gz "$DOWNLOAD_URL"

mkdir -p app_root extract
tar -xzf sonarr.tar.gz -C extract

SONARR_BIN=$(find extract -type f -name "Sonarr" | head -1)
[ -z "$SONARR_BIN" ] && { echo "Sonarr binary not found in tarball" >&2; exit 1; }
SONARR_DIR=$(dirname "$SONARR_BIN")
cp -a "$SONARR_DIR"/. app_root/
chmod +x app_root/Sonarr

mkdir -p app_root/bin app_root/ui
cp apps/sonarr/fnos/bin/sonarr-server app_root/bin/sonarr-server
chmod +x app_root/bin/sonarr-server
cp -a apps/sonarr/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
