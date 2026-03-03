#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
ZIP_ARCH="${ZIP_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building Readarr ${VERSION} for ${ZIP_ARCH}"

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

ASSET_NAME="Readarr.develop.${VERSION}.linux-core-${TARBALL_ARCH}.tar.gz"
DOWNLOAD_URL="https://github.com/Readarr/Readarr/releases/download/v${VERSION}/${ASSET_NAME}"
echo "Downloading: $DOWNLOAD_URL"
curl -fL -o readarr.tar.gz "$DOWNLOAD_URL"

mkdir -p app_root extract
tar -xzf readarr.tar.gz -C extract

READARR_BIN=$(find extract -type f -name "Readarr" | head -1)
[ -z "$READARR_BIN" ] && { echo "Readarr binary not found in tarball" >&2; exit 1; }
READARR_DIR=$(dirname "$READARR_BIN")
cp -a "$READARR_DIR"/. app_root/
chmod +x app_root/Readarr

mkdir -p app_root/bin app_root/ui
cp apps/readarr/fnos/bin/readarr-server app_root/bin/readarr-server
chmod +x app_root/bin/readarr-server
cp -a apps/readarr/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
