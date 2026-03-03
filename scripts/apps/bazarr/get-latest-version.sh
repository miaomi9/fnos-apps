#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

if [ -n "$INPUT_VERSION" ]; then
  VERSION=$(echo "$INPUT_VERSION" | sed 's/^v//')
else
  VERSION=$(curl -sL "https://hub.docker.com/v2/repositories/linuxserver/bazarr/tags?page_size=100" | \
    jq -r '[.results[].name | select(test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))][0] // empty')
fi

[ -z "$VERSION" ] && { echo "Failed to resolve version for bazarr" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
