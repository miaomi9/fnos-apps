#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
ZIP_ARCH="${ZIP_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building Beszel ${VERSION} for ${ZIP_ARCH}"

DOWNLOAD_URL="https://github.com/henrygd/beszel/releases/download/v${VERSION}/beszel_linux_${ZIP_ARCH}.tar.gz"
curl -fL -o beszel.tar.gz "$DOWNLOAD_URL"

tar -xzf beszel.tar.gz

mkdir -p app_root/bin app_root/ui
[ -f beszel ] || { echo "beszel binary not found in tarball" >&2; exit 1; }

cp beszel app_root/beszel
chmod +x app_root/beszel

cp apps/beszel/fnos/bin/beszel-server app_root/bin/beszel-server
chmod +x app_root/bin/beszel-server
cp -a apps/beszel/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
