#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="nvidia-driver"
APP_DISPLAY_NAME="NVIDIA Driver"
APP_VERSION_VAR="NVIDIA_DRIVER_VERSION"
APP_VERSION="${NVIDIA_DRIVER_VERSION:-latest}"
APP_DEPS=(curl tar)
APP_FPK_PREFIX="nvidia-driver"
APP_HELP_VERSION_EXAMPLE="580.126.20"

source "$REPO_ROOT/scripts/apps/nvidia-driver/meta.env"
NCT_VERSION="${NCT_VERSION:-1.17.8}"

app_set_arch_vars() {
    case "$ARCH" in
        x86) : ;;
        arm) error "NVIDIA datacenter 驱动仅支持 x86_64 架构" ;;
    esac
}

app_show_help_examples() {
    cat << EOF
  $0 580.126.20              # 指定驱动版本
  $0 --arch x86 580.126.20   # 指定版本和架构
  NCT_VERSION=1.17.8 $0      # 指定 nvidia-container-toolkit 版本
EOF
}

app_get_latest_version() {
    info "获取最新 R580 LTS 驱动版本..."

    if [ "$APP_VERSION" = "latest" ]; then
        local resolved
        resolved=$(bash "$REPO_ROOT/scripts/apps/nvidia-driver/get-latest-version.sh" 2>/dev/null \
            | grep "^VERSION=" | cut -d= -f2)
        if [ -n "$resolved" ]; then
            APP_VERSION="$resolved"
        fi
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 580.126.20"
    info "目标驱动版本: $APP_VERSION"
    info "nvidia-container-toolkit 版本: $NCT_VERSION"
}

app_download() {
    mkdir -p "$WORK_DIR"

    local driver_url="https://us.download.nvidia.com/tesla/${APP_VERSION}/NVIDIA-Linux-x86_64-${APP_VERSION}.run"
    info "下载 NVIDIA 驱动: $driver_url"
    curl -L -f --progress-bar -o "$WORK_DIR/NVIDIA-Linux-x86_64-${APP_VERSION}.run" "$driver_url" \
        || error "驱动下载失败"
    info "驱动下载完成: $(du -h "$WORK_DIR/NVIDIA-Linux-x86_64-${APP_VERSION}.run" | cut -f1)"

    local nct_url="https://github.com/NVIDIA/nvidia-container-toolkit/releases/download/v${NCT_VERSION}/nvidia-container-toolkit_${NCT_VERSION}_deb_amd64.tar.gz"
    info "下载 nvidia-container-toolkit: $nct_url"
    curl -L -f --progress-bar -o "$WORK_DIR/nct.tar.gz" "$nct_url" \
        || error "nvidia-container-toolkit 下载失败"
    info "toolkit 下载完成: $(du -h "$WORK_DIR/nct.tar.gz" | cut -f1)"
}

app_build_app_tgz() {
    info "构建 app.tgz..."
    cd "$WORK_DIR"

    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/nvidia-container-toolkit"

    cp "NVIDIA-Linux-x86_64-${APP_VERSION}.run" "$dst/"
    chmod +x "$dst/NVIDIA-Linux-x86_64-${APP_VERSION}.run"

    info "提取 nvidia-container-toolkit .deb 包..."
    mkdir -p nct_extracted
    tar -xzf nct.tar.gz -C nct_extracted

    local deb_dir
    deb_dir=$(find nct_extracted -type d -name "amd64" | head -1)
    [ -z "$deb_dir" ] && error "在 toolkit 压缩包中找不到 .deb 文件"

    for deb in "$deb_dir"/libnvidia-container1_*.deb \
               "$deb_dir"/libnvidia-container-tools_*.deb \
               "$deb_dir"/nvidia-container-toolkit-base_*.deb \
               "$deb_dir"/nvidia-container-toolkit_1*.deb; do
        if [ -f "$deb" ]; then
            cp "$deb" "$dst/nvidia-container-toolkit/"
            info "  包含: $(basename "$deb")"
        fi
    done

    mkdir -p "$dst/ui"
    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
