#!/bin/bash
set -euo pipefail

#
# get-latest-version.sh for nvidia-driver
#
# Resolves the latest NVIDIA R580 LTS driver version.
# Strategy: HEAD-check the known NVIDIA CDN URL pattern for R580 versions.
# Falls back to hardcoded version if detection fails.
#

INPUT_VERSION="${1:-}"

# Hardcoded fallback — update when new R580 LTS versions are released
FALLBACK_VERSION="580.126.20"

# R580 LTS branch: versions follow pattern 580.X.Y
# Known releases (chronological): 580.65.06, 580.82.07, 580.95.05,
# 580.105.08, 580.126.09, 580.126.16, 580.126.20

resolve_latest_r580() {
    # Try to find the latest R580 version by checking the NVIDIA download page
    local version=""

    # Method 1: Parse NVIDIA datacenter driver archive page
    version=$(curl -sL --connect-timeout 10 --max-time 30 \
        "https://developer.nvidia.com/datacenter-driver-archive" 2>/dev/null \
        | grep -oE '580\.[0-9]+\.[0-9]+' \
        | sort -t. -k1,1n -k2,2n -k3,3n \
        | tail -1) || true

    if [ -n "$version" ]; then
        # Verify the download URL actually exists
        local status
        status=$(curl -sI -o /dev/null -w "%{http_code}" --connect-timeout 10 --max-time 15 \
            "https://us.download.nvidia.com/tesla/${version}/NVIDIA-Linux-x86_64-${version}.run" 2>/dev/null) || true
        if [ "$status" = "200" ]; then
            echo "$version"
            return 0
        fi
    fi

    # Method 2: HEAD-check the fallback version
    local status
    status=$(curl -sI -o /dev/null -w "%{http_code}" --connect-timeout 10 --max-time 15 \
        "https://us.download.nvidia.com/tesla/${FALLBACK_VERSION}/NVIDIA-Linux-x86_64-${FALLBACK_VERSION}.run" 2>/dev/null) || true
    if [ "$status" = "200" ]; then
        echo "$FALLBACK_VERSION"
        return 0
    fi

    # All methods failed
    echo "$FALLBACK_VERSION"
}

if [ -n "$INPUT_VERSION" ]; then
    VERSION="$INPUT_VERSION"
else
    VERSION=$(resolve_latest_r580)
fi

[ -z "$VERSION" ] && { echo "Failed to resolve NVIDIA driver version" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
