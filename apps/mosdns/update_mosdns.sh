#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="mosdns"
APP_DISPLAY_NAME="MosDNS"
APP_VERSION_VAR="MOSDNS_VERSION"
APP_VERSION="${MOSDNS_VERSION:-latest}"
APP_DEPS=(curl tar unzip)
APP_FPK_PREFIX="mosdns"
APP_HELP_VERSION_EXAMPLE="5.3.4"

app_set_arch_vars() {
    case "$ARCH" in
        x86) ZIP_ARCH="amd64" ;;
        arm) ZIP_ARCH="arm64" ;;
    esac
    info "Zip arch: $ZIP_ARCH"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 5.3.4      # 指定版本，x86 架构
  $0 5.3.4                 # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    local tag
    tag=$(curl -sL "https://api.github.com/repos/IrineSistiana/mosdns/releases/latest" 2>/dev/null | \
        grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION="$tag"
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 5.3.4"

    info "目标版本: $APP_VERSION"
}

app_download() {
    local download_url="https://github.com/IrineSistiana/mosdns/releases/download/v${APP_VERSION}/mosdns-linux-${ZIP_ARCH}.zip"

    info "下载 ($ARCH): $download_url"
    mkdir -p "$WORK_DIR"
    curl -L -f -o "$WORK_DIR/mosdns.zip" "$download_url" || error "下载失败"
    info "下载完成: $(du -h "$WORK_DIR/mosdns.zip" | cut -f1)"
}

app_build_app_tgz() {
    info "解压 mosdns..."
    cd "$WORK_DIR"
    unzip -o mosdns.zip

    info "构建 app.tgz..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/bin" "$dst/ui" "$dst/config"

    [ -f "mosdns" ] || error "在 zip 中找不到 mosdns 二进制文件"

    cp mosdns "$dst/mosdns"
    chmod +x "$dst/mosdns"

    cp "$PKG_DIR/config/config.yaml" "$dst/config/config.yaml"
    cp "$PKG_DIR/config/cn_domains.txt" "$dst/config/cn_domains.txt"
    cp "$PKG_DIR/bin/mosdns-server" "$dst/bin/mosdns-server"
    chmod +x "$dst/bin/mosdns-server"
    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
