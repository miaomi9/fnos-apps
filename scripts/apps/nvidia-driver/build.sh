#!/bin/bash
set -euo pipefail

#
# build.sh for nvidia-driver
#
# Downloads NVIDIA driver .run installer and nvidia-container-toolkit .deb
# bundle, then packages them into app.tgz.
#
# Inputs (environment variables):
#   VERSION       — NVIDIA driver version (e.g., 580.126.20)
#   NCT_VERSION   — nvidia-container-toolkit version (from meta.env)
#
# Output: app.tgz in current directory
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/meta.env"

VERSION="${VERSION:-}"
NCT_VERSION="${NCT_VERSION:-1.17.8}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building NVIDIA Driver ${VERSION} + nvidia-container-toolkit ${NCT_VERSION}"

# ============================================================
# 1. Download NVIDIA driver .run installer (~380MB)
# ============================================================

DRIVER_URL="https://us.download.nvidia.com/tesla/${VERSION}/NVIDIA-Linux-x86_64-${VERSION}.run"
DRIVER_FILE="NVIDIA-Linux-x86_64-${VERSION}.run"

echo "==> Downloading NVIDIA driver: ${DRIVER_URL}"
curl -fL --progress-bar -o "$DRIVER_FILE" "$DRIVER_URL"

DRIVER_SIZE=$(stat -f%z "$DRIVER_FILE" 2>/dev/null || stat -c%s "$DRIVER_FILE" 2>/dev/null)
echo "==> Driver downloaded: $(( DRIVER_SIZE / 1048576 )) MB"

# Sanity check: driver should be > 100MB
if [ "${DRIVER_SIZE}" -lt 104857600 ]; then
    echo "ERROR: Driver file too small (${DRIVER_SIZE} bytes), likely corrupted" >&2
    exit 1
fi

# ============================================================
# 2. Download nvidia-container-toolkit .deb bundle (~10MB)
# ============================================================

NCT_URL="https://github.com/NVIDIA/nvidia-container-toolkit/releases/download/v${NCT_VERSION}/nvidia-container-toolkit_${NCT_VERSION}_deb_amd64.tar.gz"
NCT_ARCHIVE="nvidia-container-toolkit_${NCT_VERSION}_deb_amd64.tar.gz"

echo "==> Downloading nvidia-container-toolkit: ${NCT_URL}"
curl -fL --progress-bar -o "$NCT_ARCHIVE" "$NCT_URL"

# ============================================================
# 3. Extract toolkit .deb files
# ============================================================

echo "==> Extracting nvidia-container-toolkit packages..."
mkdir -p nct_extracted
tar -xzf "$NCT_ARCHIVE" -C nct_extracted

# Find the .deb files (they're in a nested directory structure)
# Pattern: release-v*/packages/ubuntu18.04/amd64/*.deb
NCT_DEB_DIR=$(find nct_extracted -type d -name "amd64" | head -1)
if [ -z "$NCT_DEB_DIR" ]; then
    echo "ERROR: Could not find .deb files in toolkit archive" >&2
    exit 1
fi

# ============================================================
# 4. Assemble app.tgz
# ============================================================

echo "==> Building app.tgz..."
mkdir -p app_root/nvidia-container-toolkit

# Copy driver installer
cp "$DRIVER_FILE" app_root/
chmod +x "app_root/$DRIVER_FILE"

# Copy required toolkit .deb files (skip -dev, -dbg, -operator-extensions)
for deb in "$NCT_DEB_DIR"/libnvidia-container1_*.deb \
           "$NCT_DEB_DIR"/libnvidia-container-tools_*.deb \
           "$NCT_DEB_DIR"/nvidia-container-toolkit-base_*.deb \
           "$NCT_DEB_DIR"/nvidia-container-toolkit_1*.deb; do
    if [ -f "$deb" ]; then
        cp "$deb" app_root/nvidia-container-toolkit/
        echo "  Included: $(basename "$deb")"
    fi
done

# Copy ui/ directory
cp -a "apps/nvidia-driver/fnos/ui" app_root/ui

# Create app.tgz
cd app_root
tar -czf ../app.tgz .
cd ..

APP_SIZE=$(stat -f%z app.tgz 2>/dev/null || stat -c%s app.tgz 2>/dev/null)
echo "==> Built app.tgz: $(( APP_SIZE / 1048576 )) MB"

# Clean up
rm -rf app_root nct_extracted "$DRIVER_FILE" "$NCT_ARCHIVE"

echo "==> Done"
