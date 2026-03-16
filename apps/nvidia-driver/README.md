# NVIDIA Driver for fnOS

NVIDIA GPU 驱动程序（R580 LTS）与 nvidia-container-toolkit 一体化安装包。

## 功能

- NVIDIA R580 LTS 驱动（DKMS 编译，支持内核更新自动重编译）
- nvidia-container-toolkit（Docker GPU 直通支持）
- 自动配置 Docker nvidia runtime
- 自动配置内核模块开机加载
- 自动启用 GPU Persistence Mode

## 前提条件

- fnOS 1.1.x（Debian 12 Bookworm）
- NVIDIA GPU（Pascal 及以上架构）
- 内核头文件：`apt install linux-headers-$(uname -r)`
- 编译工具：`apt install build-essential`

## 安装后验证

```bash
# 检查驱动
nvidia-smi

# 检查 Docker GPU 支持
docker run --rm --gpus all ubuntu:22.04 nvidia-smi
```

## 本地构建

```bash
cd apps/nvidia-driver
./update_nvidia-driver.sh                    # 自动获取最新 R580 版本
./update_nvidia-driver.sh 580.126.20         # 指定驱动版本
NCT_VERSION=1.17.8 ./update_nvidia-driver.sh # 指定 toolkit 版本
```

## 注意事项

- 仅支持 x86_64 架构
- 不应与飞牛商店的 `Nvidia-Driver` 包共存
- 如遇 GPU 掉卡（Xid 79），建议添加内核参数 `pcie_aspm=off`
- 详细安装指南参考 `docs/fnos-tesla-p4-driver-guide.md`
