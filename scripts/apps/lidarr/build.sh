#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
ZIP_ARCH="${ZIP_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building Lidarr ${VERSION} for ${ZIP_ARCH}"

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

ASSET_NAME="Lidarr.master.${VERSION}.linux-core-${TARBALL_ARCH}.tar.gz"
DOWNLOAD_URL="https://github.com/Lidarr/Lidarr/releases/download/v${VERSION}/${ASSET_NAME}"
echo "Downloading: $DOWNLOAD_URL"
curl -fL -o lidarr.tar.gz "$DOWNLOAD_URL"

mkdir -p app_root extract
tar -xzf lidarr.tar.gz -C extract

LIDARR_BIN=$(find extract -type f -name "Lidarr" | head -1)
[ -z "$LIDARR_BIN" ] && { echo "Lidarr binary not found in tarball" >&2; exit 1; }
LIDARR_DIR=$(dirname "$LIDARR_BIN")
cp -a "$LIDARR_DIR"/. app_root/
chmod +x app_root/Lidarr

mkdir -p app_root/bin app_root/ui
cp apps/lidarr/fnos/bin/lidarr-server app_root/bin/lidarr-server
chmod +x app_root/bin/lidarr-server
cp -a apps/lidarr/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
