#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

# Query npm registry for latest version
VERSION=$(curl -sL "https://registry.npmjs.org/openclaw/latest" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
fi

[ -z "$VERSION" ] || [ "$VERSION" = "null" ] && { echo "Failed to resolve version for openclaw" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
