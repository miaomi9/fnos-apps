#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  TOKEN=$(curl -s "https://ghcr.io/token?scope=repository:requarks/wiki:pull" | jq -r '.token')
  VERSION=$(curl -s -H "Authorization: Bearer ${TOKEN}" "https://ghcr.io/v2/requarks/wiki/tags/list" | \
    jq -r '[.tags[] | select(test("^2\\.[0-9]+\\.[0-9]+$"))] | sort_by(split(".") | map(tonumber)) | last')
fi

VERSION=$(echo "$VERSION" | sed 's/^v//')

[ -z "$VERSION" ] && { echo "Failed to resolve version for wikijs" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
