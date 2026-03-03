#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

TAG=$(curl -sL "https://api.github.com/repos/henrygd/beszel/releases/latest" | \
  jq -r '.tag_name')

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  VERSION=$(echo "$TAG" | sed 's/^v//')
fi

[ -z "$VERSION" ] && { echo "Failed to resolve version for beszel" >&2; exit 1; }

echo "VERSION=$VERSION"
echo "UPSTREAM_TAG=v$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
  echo "upstream_tag=v$VERSION" >> "$GITHUB_OUTPUT"
fi
