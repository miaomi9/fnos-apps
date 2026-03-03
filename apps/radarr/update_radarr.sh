#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="radarr"
APP_DISPLAY_NAME="Radarr"
APP_VERSION_VAR="RADARR_VERSION"
APP_VERSION="${RADARR_VERSION:-latest}"
APP_DEPS=(curl tar jq)
APP_FPK_PREFIX="radarr"
APP_HELP_VERSION_EXAMPLE="6.0.4.10291"

app_set_arch_vars() {
    case "$ARCH" in
        x86) TAR_ARCH="x64" ;;
        arm) TAR_ARCH="arm64" ;;
    esac
    info "Tar arch: $TAR_ARCH"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 6.0.4.10291  # 指定版本，x86 架构
  $0 6.0.4.10291             # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION=$(curl -sL "https://api.github.com/repos/Radarr/Radarr/releases/latest" | \
          jq -r '.tag_name' | sed 's/^v//')
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 6.0.4.10291"
    info "目标版本: $APP_VERSION"
}

app_download() {
    local asset_name="Radarr.master.${APP_VERSION}.linux-core-${TAR_ARCH}.tar.gz"
    local download_url="https://github.com/Radarr/Radarr/releases/download/v${APP_VERSION}/${asset_name}"

    info "下载 ($ARCH): $download_url"
    mkdir -p "$WORK_DIR"
    curl -L -f -o "$WORK_DIR/radarr.tar.gz" "$download_url" || error "下载失败"
    info "下载完成: $(du -h "$WORK_DIR/radarr.tar.gz" | cut -f1)"
}

app_build_app_tgz() {
    info "解压 Radarr..."
    cd "$WORK_DIR"
    mkdir -p extract
    tar -xzf radarr.tar.gz -C extract

    info "构建 app.tgz..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst"

    local app_bin
    app_bin=$(find extract -type f -name "Radarr" | head -1)
    [ -z "$app_bin" ] && error "在 tar.gz 中找不到 Radarr 二进制文件"

    local app_dir
    app_dir=$(dirname "$app_bin")
    cp -a "$app_dir"/. "$dst/"
    chmod +x "$dst/Radarr"

    mkdir -p "$dst/bin" "$dst/ui"
    cp "$PKG_DIR/bin/radarr-server" "$dst/bin/radarr-server"
    chmod +x "$dst/bin/radarr-server"
    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
