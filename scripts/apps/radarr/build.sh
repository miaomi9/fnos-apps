#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
ZIP_ARCH="${ZIP_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building Radarr ${VERSION} for ${ZIP_ARCH}"

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

ASSET_NAME="Radarr.master.${VERSION}.linux-core-${TARBALL_ARCH}.tar.gz"
DOWNLOAD_URL="https://github.com/Radarr/Radarr/releases/download/v${VERSION}/${ASSET_NAME}"
echo "Downloading: $DOWNLOAD_URL"
curl -fL -o radarr.tar.gz "$DOWNLOAD_URL"

mkdir -p app_root extract
tar -xzf radarr.tar.gz -C extract

RADARR_BIN=$(find extract -type f -name "Radarr" | head -1)
[ -z "$RADARR_BIN" ] && { echo "Radarr binary not found in tarball" >&2; exit 1; }
RADARR_DIR=$(dirname "$RADARR_BIN")
cp -a "$RADARR_DIR"/. app_root/
chmod +x app_root/Radarr

mkdir -p app_root/bin app_root/ui
cp apps/radarr/fnos/bin/radarr-server app_root/bin/radarr-server
chmod +x app_root/bin/radarr-server
cp -a apps/radarr/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
