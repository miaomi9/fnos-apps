#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="wikijs"
APP_DISPLAY_NAME="Wiki.js"
APP_VERSION_VAR="WIKIJS_VERSION"
APP_VERSION="${WIKIJS_VERSION:-latest}"
APP_DEPS=(curl tar jq)
APP_FPK_PREFIX="wikijs"
APP_HELP_VERSION_EXAMPLE="2.5.277"

app_set_arch_vars() {
    :
}

app_show_help_examples() {
    cat << EOF
  $0 2.5.277                # 指定版本
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    if [ "$APP_VERSION" = "latest" ]; then
        local token
        token=$(curl -s "https://ghcr.io/token?scope=repository:requarks/wiki:pull" | jq -r '.token')
        APP_VERSION=$(curl -s -H "Authorization: Bearer ${token}" "https://ghcr.io/v2/requarks/wiki/tags/list" | \
            jq -r '[.tags[] | select(test("^2\\.[0-9]+\\.[0-9]+$"))] | sort_by(split(".") | map(tonumber)) | last')
    fi

    APP_VERSION=$(echo "$APP_VERSION" | sed 's/^v//')

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 2.5.277"
    info "目标版本: $APP_VERSION"
}

app_download() {
    :
}

app_build_app_tgz() {
    info "构建 app.tgz (Docker)..."
    export VERSION="$APP_VERSION"
    bash "$REPO_ROOT/scripts/apps/wikijs/build.sh"
    cp "$REPO_ROOT/app.tgz" "$WORK_DIR/app.tgz"
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
