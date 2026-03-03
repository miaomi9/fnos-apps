#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
UPSTREAM_TAG="${UPSTREAM_TAG:-}"
ARCH="${DEB_ARCH:-amd64}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }
[ -z "$UPSTREAM_TAG" ] && { echo "UPSTREAM_TAG is required" >&2; exit 1; }

case "$ARCH" in
  amd64|x86_64)
    PKG_ARCH="x86_64"
    ;;
  arm64|aarch64)
    PKG_ARCH="aarch64"
    ;;
  *)
    echo "Unsupported architecture: $ARCH" >&2
    exit 1
    ;;
esac

echo "==> Building SmartDNS ${VERSION} for ${PKG_ARCH}"

DOWNLOAD_URL="https://github.com/pymumu/smartdns/releases/download/${UPSTREAM_TAG}/smartdns.${VERSION}.${PKG_ARCH}-linux-all.tar.gz"
curl -fL -o smartdns.tar.gz "$DOWNLOAD_URL"

tar -xzf smartdns.tar.gz

[ -f "smartdns/usr/local/lib/smartdns/smartdns" ] || { echo "smartdns binary not found in package" >&2; exit 1; }
[ -f "smartdns/usr/local/lib/smartdns/run-smartdns" ] || { echo "run-smartdns launcher not found in package" >&2; exit 1; }
[ -d "smartdns/usr/share/smartdns/wwwroot" ] || { echo "smartdns web UI files not found in package" >&2; exit 1; }

mkdir -p app_root/bin app_root/ui app_root/config
cp -a "smartdns/usr/local/lib/smartdns" app_root/runtime
chmod +x app_root/runtime/smartdns app_root/runtime/run-smartdns
cp -a "smartdns/usr/share/smartdns/wwwroot" app_root/runtime/wwwroot

cp apps/smartdns/fnos/config/smartdns.conf app_root/config/smartdns.conf
cp apps/smartdns/fnos/bin/smartdns-server app_root/bin/smartdns-server
chmod +x app_root/bin/smartdns-server
cp -a apps/smartdns/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
