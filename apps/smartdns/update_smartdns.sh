#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="smartdns"
APP_DISPLAY_NAME="SmartDNS"
APP_VERSION_VAR="SMARTDNS_VERSION"
APP_VERSION="${SMARTDNS_VERSION:-latest}"
APP_DEPS=(curl tar jq)
APP_FPK_PREFIX="smartdns"
APP_HELP_VERSION_EXAMPLE="1.2025.11.09-1443"

app_set_arch_vars() {
    case "$ARCH" in
        x86) PKG_ARCH="x86_64" ;;
        arm) PKG_ARCH="aarch64" ;;
    esac
    info "Package arch: $PKG_ARCH"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 1.2025.11.09-1443   # 指定版本，x86 架构
  $0 1.2025.11.09-1443              # 指定版本，自动检测架构
EOF
}

resolve_version_from_release() {
    local release_json="$1"
    echo "$release_json" | jq -r --arg arch "$PKG_ARCH" '.assets[]?.name | select(test("^smartdns\\..*\\." + $arch + "-linux-all\\.tar\\.gz$"))' | \
        sed -E 's/^smartdns\.([^.]\..*\.[0-9]+-[0-9]+)\..*$/\1/' | head -1
}

app_get_latest_version() {
    info "获取版本信息..."

    local latest_json release_json
    latest_json=$(curl -sL "https://api.github.com/repos/pymumu/smartdns/releases/latest")

    if [ "$APP_VERSION" = "latest" ]; then
        RELEASE_TAG=$(echo "$latest_json" | jq -r '.tag_name')
        APP_VERSION=$(resolve_version_from_release "$latest_json")
    elif echo "$APP_VERSION" | grep -q '^Release'; then
        RELEASE_TAG="$APP_VERSION"
        release_json=$(curl -sL "https://api.github.com/repos/pymumu/smartdns/releases/tags/${RELEASE_TAG}")
        APP_VERSION=$(resolve_version_from_release "$release_json")
    else
        RELEASE_TAG=$(curl -sL "https://api.github.com/repos/pymumu/smartdns/releases?per_page=100" | \
            jq -r --arg version "$APP_VERSION" --arg arch "$PKG_ARCH" '.[] | select(any(.assets[]?; .name == ("smartdns." + $version + "." + $arch + "-linux-all.tar.gz"))) | .tag_name' | head -1)
    fi

    [ -z "$RELEASE_TAG" ] && error "无法找到版本 ${APP_VERSION} 对应的 release tag"
    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 1.2025.11.09-1443"

    info "Release tag: $RELEASE_TAG"
    info "目标版本: $APP_VERSION"
}

app_download() {
    local download_url="https://github.com/pymumu/smartdns/releases/download/${RELEASE_TAG}/smartdns.${APP_VERSION}.${PKG_ARCH}-linux-all.tar.gz"

    info "下载 ($ARCH): $download_url"
    mkdir -p "$WORK_DIR"
    curl -L -f -o "$WORK_DIR/smartdns.tar.gz" "$download_url" || error "下载失败"
    info "下载完成: $(du -h "$WORK_DIR/smartdns.tar.gz" | cut -f1)"
}

app_build_app_tgz() {
    info "解压 smartdns..."
    cd "$WORK_DIR"
    tar -xzf smartdns.tar.gz

    info "构建 app.tgz..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/bin" "$dst/ui" "$dst/config"

    [ -f "smartdns/usr/local/lib/smartdns/smartdns" ] || error "在 tar.gz 中找不到 smartdns 二进制文件"
    [ -f "smartdns/usr/local/lib/smartdns/run-smartdns" ] || error "在 tar.gz 中找不到 run-smartdns 启动器"
    [ -d "smartdns/usr/share/smartdns/wwwroot" ] || error "在 tar.gz 中找不到 SmartDNS Web UI 文件"

    cp -a "smartdns/usr/local/lib/smartdns" "$dst/runtime"
    chmod +x "$dst/runtime/smartdns" "$dst/runtime/run-smartdns"
    cp -a "smartdns/usr/share/smartdns/wwwroot" "$dst/runtime/wwwroot"

    cp "$PKG_DIR/config/smartdns.conf" "$dst/config/smartdns.conf"
    cp "$PKG_DIR/bin/smartdns-server" "$dst/bin/smartdns-server"
    chmod +x "$dst/bin/smartdns-server"
    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
