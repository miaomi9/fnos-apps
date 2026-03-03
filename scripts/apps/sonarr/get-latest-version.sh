#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

TAG=$(curl -sL "https://api.github.com/repos/Sonarr/Sonarr/releases/latest" | \
  jq -r '.tag_name')

if [ -n "$INPUT_VERSION" ]; then
  VERSION=$(echo "$INPUT_VERSION" | sed 's/^v//')
else
  VERSION=$(echo "$TAG" | sed 's/^v//')
fi

[ -z "$VERSION" ] && { echo "Failed to resolve version for sonarr" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
