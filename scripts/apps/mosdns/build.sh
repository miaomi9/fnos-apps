#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
ZIP_ARCH="${ZIP_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building MosDNS ${VERSION} for ${ZIP_ARCH}"

DOWNLOAD_URL="https://github.com/IrineSistiana/mosdns/releases/download/v${VERSION}/mosdns-linux-${ZIP_ARCH}.zip"
curl -fL -o mosdns.zip "$DOWNLOAD_URL"

unzip -o mosdns.zip

[ -f mosdns ] || { echo "mosdns binary not found in zip" >&2; exit 1; }

mkdir -p app_root/bin app_root/ui app_root/config
cp mosdns app_root/mosdns
chmod +x app_root/mosdns

cp apps/mosdns/fnos/config/config.yaml app_root/config/config.yaml
cp apps/mosdns/fnos/config/cn_domains.txt app_root/config/cn_domains.txt
cp apps/mosdns/fnos/bin/mosdns-server app_root/bin/mosdns-server
chmod +x app_root/bin/mosdns-server
cp -a apps/mosdns/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
