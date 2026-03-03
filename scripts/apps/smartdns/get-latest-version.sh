#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"
ARCH="${DEB_ARCH:-amd64}"

case "$ARCH" in
  amd64|x86_64)
    PKG_ARCH="x86_64"
    ;;
  arm64|aarch64)
    PKG_ARCH="aarch64"
    ;;
  *)
    echo "Unsupported architecture for smartdns: $ARCH" >&2
    exit 1
    ;;
esac

resolve_version_from_release() {
  local release_json="$1"
  echo "$release_json" | jq -r --arg arch "$PKG_ARCH" '.assets[]?.name | select(test("^smartdns\\..*\\." + $arch + "-linux-all\\.tar\\.gz$"))' | \
    sed -E 's/^smartdns\.([^.]\..*\.[0-9]+-[0-9]+)\..*$/\1/' | head -1
}

LATEST_JSON=$(curl -sL "https://api.github.com/repos/pymumu/smartdns/releases/latest")

if [ -z "$INPUT_VERSION" ]; then
  UPSTREAM_TAG=$(echo "$LATEST_JSON" | jq -r '.tag_name')
  VERSION=$(resolve_version_from_release "$LATEST_JSON")
elif echo "$INPUT_VERSION" | grep -q '^Release'; then
  UPSTREAM_TAG="$INPUT_VERSION"
  RELEASE_JSON=$(curl -sL "https://api.github.com/repos/pymumu/smartdns/releases/tags/${UPSTREAM_TAG}")
  VERSION=$(resolve_version_from_release "$RELEASE_JSON")
else
  VERSION="$INPUT_VERSION"
  UPSTREAM_TAG=$(curl -sL "https://api.github.com/repos/pymumu/smartdns/releases?per_page=100" | \
    jq -r --arg version "$VERSION" --arg arch "$PKG_ARCH" '.[] | select(any(.assets[]?; .name == ("smartdns." + $version + "." + $arch + "-linux-all.tar.gz"))) | .tag_name' | head -1)
fi

[ -z "$VERSION" ] && { echo "Failed to resolve version for smartdns" >&2; exit 1; }
[ -z "$UPSTREAM_TAG" ] && { echo "Failed to resolve upstream tag for smartdns" >&2; exit 1; }

echo "VERSION=$VERSION"
echo "UPSTREAM_TAG=$UPSTREAM_TAG"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
  echo "upstream_tag=$UPSTREAM_TAG" >> "$GITHUB_OUTPUT"
fi
