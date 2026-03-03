#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="photoprism"
APP_DISPLAY_NAME="PhotoPrism"
APP_VERSION_VAR="PHOTOPRISM_VERSION"
APP_VERSION="${PHOTOPRISM_VERSION:-latest}"
APP_DEPS=(curl tar jq)
APP_FPK_PREFIX="photoprism"
APP_HELP_VERSION_EXAMPLE="251130"

app_set_arch_vars() {
    :
}

app_show_help_examples() {
    cat << EOF
  $0 251130                 # 指定版本
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION=$(curl -sL "https://api.github.com/repos/photoprism/photoprism/releases/latest" | \
          jq -r '.tag_name')
    fi

    APP_VERSION=$(echo "$APP_VERSION" | sed 's/^v//' | sed 's/-.*$//')

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 251130"
    info "目标版本: $APP_VERSION"
}

app_download() {
    :
}

app_build_app_tgz() {
    info "构建 app.tgz (Docker)..."
    export VERSION="$APP_VERSION"
    bash "$REPO_ROOT/scripts/apps/photoprism/build.sh"
    cp "$REPO_ROOT/app.tgz" "$WORK_DIR/app.tgz"
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
