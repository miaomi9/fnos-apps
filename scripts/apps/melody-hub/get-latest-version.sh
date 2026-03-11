#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

# melody-hub has no GitHub releases; version is tracked via Docker Hub tags.
# Tags: v1.0.0, v1.0.1, etc.  We query Docker Hub API for the latest vX.Y.Z tag.

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  # Get all tags matching v*, sort by version, pick latest
  VERSION=$(curl -sL "https://hub.docker.com/v2/repositories/geelonn/melodyhub/tags?page_size=100&ordering=last_updated" | \
    jq -r '.results[].name' | \
    grep '^v[0-9]' | \
    sed 's/^v//' | \
    sort -V | \
    tail -1)
fi

[ -z "$VERSION" ] || [ "$VERSION" = "null" ] && { echo "Failed to resolve version for melody-hub" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
