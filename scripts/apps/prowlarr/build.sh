#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
ZIP_ARCH="${ZIP_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building Prowlarr ${VERSION} for ${ZIP_ARCH}"

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

ASSET_NAME="Prowlarr.master.${VERSION}.linux-core-${TARBALL_ARCH}.tar.gz"
DOWNLOAD_URL="https://github.com/Prowlarr/Prowlarr/releases/download/v${VERSION}/${ASSET_NAME}"
echo "Downloading: $DOWNLOAD_URL"
curl -fL -o prowlarr.tar.gz "$DOWNLOAD_URL"

mkdir -p app_root extract
tar -xzf prowlarr.tar.gz -C extract

PROWLARR_BIN=$(find extract -type f -name "Prowlarr" | head -1)
[ -z "$PROWLARR_BIN" ] && { echo "Prowlarr binary not found in tarball" >&2; exit 1; }
PROWLARR_DIR=$(dirname "$PROWLARR_BIN")
cp -a "$PROWLARR_DIR"/. app_root/
chmod +x app_root/Prowlarr

mkdir -p app_root/bin app_root/ui
cp apps/prowlarr/fnos/bin/prowlarr-server app_root/bin/prowlarr-server
chmod +x app_root/bin/prowlarr-server
cp -a apps/prowlarr/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
