#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
ZIP_ARCH="${ZIP_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building ChineseSubFinder ${VERSION} for ${ZIP_ARCH}"

case "$ZIP_ARCH" in
  amd64) ASSET_ARCH="x86_64" ;;
  arm64) ASSET_ARCH="arm64" ;;
  *) echo "Unsupported arch: $ZIP_ARCH" >&2; exit 1 ;;
esac

DOWNLOAD_URL="https://github.com/ChineseSubFinder/ChineseSubFinder/releases/download/v${VERSION}/chinesesubfinder_Linux_${ASSET_ARCH}_${VERSION}.tar.gz"
curl -fL -o chinesesubfinder.tar.gz "$DOWNLOAD_URL"

tar -xzf chinesesubfinder.tar.gz

mkdir -p app_root/bin app_root/ui
APP_BIN=$(find . -name "chinesesubfinder" -type f | head -1)
[ -z "$APP_BIN" ] && { echo "chinesesubfinder binary not found in tar.gz" >&2; exit 1; }

cp "$APP_BIN" app_root/chinesesubfinder
chmod +x app_root/chinesesubfinder

cp apps/chinesesubfinder/fnos/bin/chinesesubfinder-server app_root/bin/chinesesubfinder-server
chmod +x app_root/bin/chinesesubfinder-server
cp -a apps/chinesesubfinder/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
