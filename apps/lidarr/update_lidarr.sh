#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="lidarr"
APP_DISPLAY_NAME="Lidarr"
APP_VERSION_VAR="LIDARR_VERSION"
APP_VERSION="${LIDARR_VERSION:-latest}"
APP_DEPS=(curl tar jq)
APP_FPK_PREFIX="lidarr"
APP_HELP_VERSION_EXAMPLE="3.1.0.4875"

app_set_arch_vars() {
    case "$ARCH" in
        x86) TAR_ARCH="x64" ;;
        arm) TAR_ARCH="arm64" ;;
    esac
    info "Tar arch: $TAR_ARCH"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 3.1.0.4875  # 指定版本，x86 架构
  $0 3.1.0.4875             # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION=$(curl -sL "https://api.github.com/repos/Lidarr/Lidarr/releases/latest" | \
          jq -r '.tag_name' | sed 's/^v//')
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 3.1.0.4875"
    info "目标版本: $APP_VERSION"
}

app_download() {
    local asset_name="Lidarr.master.${APP_VERSION}.linux-core-${TAR_ARCH}.tar.gz"
    local download_url="https://github.com/Lidarr/Lidarr/releases/download/v${APP_VERSION}/${asset_name}"

    info "下载 ($ARCH): $download_url"
    mkdir -p "$WORK_DIR"
    curl -L -f -o "$WORK_DIR/lidarr.tar.gz" "$download_url" || error "下载失败"
    info "下载完成: $(du -h "$WORK_DIR/lidarr.tar.gz" | cut -f1)"
}

app_build_app_tgz() {
    info "解压 Lidarr..."
    cd "$WORK_DIR"
    mkdir -p extract
    tar -xzf lidarr.tar.gz -C extract

    info "构建 app.tgz..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst"

    local app_bin
    app_bin=$(find extract -type f -name "Lidarr" | head -1)
    [ -z "$app_bin" ] && error "在 tar.gz 中找不到 Lidarr 二进制文件"

    local app_dir
    app_dir=$(dirname "$app_bin")
    cp -a "$app_dir"/. "$dst/"
    chmod +x "$dst/Lidarr"

    mkdir -p "$dst/bin" "$dst/ui"
    cp "$PKG_DIR/bin/lidarr-server" "$dst/bin/lidarr-server"
    chmod +x "$dst/bin/lidarr-server"
    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
