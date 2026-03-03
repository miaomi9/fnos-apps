#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
ZIP_ARCH="${ZIP_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building FileBrowser ${VERSION} for ${ZIP_ARCH}"

DOWNLOAD_URL="https://github.com/filebrowser/filebrowser/releases/download/v${VERSION}/linux-${ZIP_ARCH}-filebrowser.tar.gz"
curl -fL -o filebrowser.tar.gz "$DOWNLOAD_URL"

tar -xzf filebrowser.tar.gz

mkdir -p app_root/bin app_root/ui
APP_BIN=$(find . -name "filebrowser" -type f | head -1)
[ -z "$APP_BIN" ] && { echo "filebrowser binary not found in tar.gz" >&2; exit 1; }

cp "$APP_BIN" app_root/filebrowser
chmod +x app_root/filebrowser

cp apps/filebrowser/fnos/bin/filebrowser-server app_root/bin/filebrowser-server
chmod +x app_root/bin/filebrowser-server
cp -a apps/filebrowser/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
