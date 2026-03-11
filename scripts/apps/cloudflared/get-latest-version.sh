#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  TAG=$(curl -fsSL "https://api.github.com/repos/WisdomSky/Cloudflared-web/releases/latest" 2>/dev/null | jq -r '.tag_name // empty' || true)

  if [ -n "$TAG" ]; then
    VERSION=$(echo "$TAG" | sed -E 's/^v//')
  else
    VERSION=$(curl -fsSL "https://hub.docker.com/v2/repositories/wisdomsky/cloudflared-web/tags?page_size=20" | jq -r '.results[] | select(.name != "latest") | .name' | grep -E '^[0-9]+(\.[0-9]+)+$' | head -n 1)
  fi
fi

[ -z "$VERSION" ] || [ "$VERSION" = "null" ] && { echo "Failed to resolve version for cloudflared" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
