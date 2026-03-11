#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

# Query Docker Hub API for latest tag
TAG=$(curl -sL "https://hub.docker.com/v2/repositories/surveyking/surveyking/tags/?page_size=10&ordering=last_updated" | \
  jq -r '.results[0].name' 2>/dev/null || echo "")

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
elif [ -n "$TAG" ]; then
  VERSION=$(echo "$TAG" | sed 's/^v//')
else
  VERSION=""
fi

[ -z "$VERSION" ] || [ "$VERSION" = "null" ] && { echo "Failed to resolve version for surveyking" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
