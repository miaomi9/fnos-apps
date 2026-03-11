#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  VERSION=$(curl -sL "https://api.github.com/repos/miniflux/v2/releases/latest" | \
    jq -r '.tag_name')
fi

VERSION=$(echo "$VERSION" | sed 's/^v//')

[ -z "$VERSION" ] || [ "$VERSION" = "null" ] && { echo "Failed to resolve version for miniflux" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
