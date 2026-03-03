#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
ZIP_ARCH="${ZIP_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building Lucky ${VERSION} for ${ZIP_ARCH}"

case "$ZIP_ARCH" in
  amd64) ASSET_ARCH="x86_64" ;;
  arm64) ASSET_ARCH="arm64" ;;
  *) echo "Unsupported arch: $ZIP_ARCH" >&2; exit 1 ;;
esac

DOWNLOAD_URL="https://github.com/gdy666/lucky/releases/download/v${VERSION}/lucky_${VERSION}_Linux_${ASSET_ARCH}.tar.gz"
curl -fL -o lucky.tar.gz "$DOWNLOAD_URL"

tar -xzf lucky.tar.gz

mkdir -p app_root/bin app_root/ui
LUCKY_BIN=$(find . -name "lucky" -type f | head -1)
[ -z "$LUCKY_BIN" ] && { echo "lucky binary not found in tar.gz" >&2; exit 1; }

cp "$LUCKY_BIN" app_root/lucky
chmod +x app_root/lucky

cp apps/lucky/fnos/bin/lucky-server app_root/bin/lucky-server
chmod +x app_root/bin/lucky-server
cp -a apps/lucky/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
