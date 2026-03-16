# FnOS Tesla P4 驱动安装指南

> 适用于飞牛 FnOS 1.1.x (Debian 12 Bookworm) + Tesla P4 (GP104GL, Pascal)
> 驱动版本：NVIDIA R580 LTS (580.126.20)，支持至 2028.08
> 编写日期：2026-03-15

---

## 目录

1. [为什么不用商店驱动](#1-为什么不用商店驱动)
2. [前置条件](#2-前置条件)
3. [卸载商店驱动](#3-卸载商店驱动)
4. [清理残留文件](#4-清理残留文件)
5. [安装 NVIDIA 驱动](#5-安装-nvidia-驱动)
6. [安装 nvidia-container-toolkit](#6-安装-nvidia-container-toolkit)
7. [配置 Docker GPU 支持](#7-配置-docker-gpu-支持)
8. [配置系统参数](#8-配置系统参数)
9. [GPU 风扇自动调速](#9-gpu-风扇自动调速)
10. [验证清单](#10-验证清单)
11. [故障排查](#11-故障排查)
12. [FPK 打包要点](#12-fpk-打包要点)

---

## 1. 为什么不用商店驱动

飞牛商店的 `Nvidia-Driver-560` 存在以下问题：

| 问题 | 影响 |
|---|---|
| 库文件权限为 `660`，属主 `conversun:Users` | Plex/Emby 等应用用户无法访问 GPU |
| 库文件是独立副本而非符号链接 | nvidia-container-toolkit 无法正常工作 |
| 安装后未执行 `ldconfig` | 动态链接器找不到 NVIDIA 库 |
| 驱动版本 560.28.03 已 EOL | 无安全补丁和 bug 修复 |

使用 NVIDIA 官方 `.run` 安装器可完全避免上述问题。

---

## 2. 前置条件

```bash
# 确认内核头文件可用（DKMS 编译内核模块需要）
ls /lib/modules/$(uname -r)/build
dpkg -l | grep linux-headers

# 确认 Tesla P4 被识别
lspci | grep -i nvidia
# 期望输出: 01:00.0 3D controller: NVIDIA Corporation GP104GL [Tesla P4]

# 确认 build-essential
apt install -y build-essential linux-headers-$(uname -r)
```

---

## 3. 卸载商店驱动

在飞牛 Web UI 应用商店中卸载：
- `Nvidia-Driver-560`
- `NVIDIA Container Toolkit`

**注意**：商店卸载不会清理干净，必须执行下一步手动清理。

---

## 4. 清理残留文件

```bash
# 停止使用 GPU 的进程
fuser -k /dev/nvidia* 2>/dev/null

# 卸载内核模块
rmmod nvidia_uvm nvidia_drm nvidia_modeset nvidia 2>/dev/null

# 清理旧库文件（两个目录都要清）
for dir in /usr/lib/x86_64-linux-gnu /lib/x86_64-linux-gnu; do
  rm -f ${dir}/libnvidia-*.so*
  rm -f ${dir}/libcuda*.so*
  rm -f ${dir}/libnvcuvid.so*
  rm -f ${dir}/libnvoptix.so*
  rm -f ${dir}/libGLX_nvidia.so*
  rm -f ${dir}/libGLES*_nvidia.so*
  rm -f ${dir}/libEGL_nvidia.so*
  rm -f ${dir}/libOpenCL.so*
  rm -f ${dir}/libvdpau_nvidia.so*
done
rm -f /usr/lib/x86_64-linux-gnu/vdpau/libvdpau_nvidia.so*

# 清理旧内核模块
rm -f /usr/lib/modules/*/kernel/drivers/video/nvidia*.ko
rm -f /lib/modules/*/kernel/drivers/video/nvidia*.ko

# 清理旧二进制
rm -f /usr/bin/nvidia-{bug-report.sh,cuda-mps-control,cuda-mps-server}
rm -f /usr/bin/nvidia-{debugdump,installer,modprobe,ngx-updater,pcc}
rm -f /usr/bin/nvidia-{persistenced,powerd,settings,sleep.sh,smi,uninstall,xconfig}

# 清理杂项
rm -f /etc/cdi/nvidia.yaml
rm -rf /usr/lib/nvidia /usr/lib/firmware/nvidia
rm -f /usr/lib/xorg/modules/drivers/nvidia_drv.so
rm -f /usr/lib/xorg/modules/extensions/libglxserver_nvidia.so*
rm -rf /usr/lib/x86_64-linux-gnu/nvidia
rm -f /usr/lib/systemd/system/nvidia-*.service
rm -rf /usr/lib/systemd/system-sleep/nvidia

# 刷新动态链接器缓存
ldconfig
```

---

## 5. 安装 NVIDIA 驱动

```bash
# 下载 R580 LTS 驱动
wget -O /root/NVIDIA-Linux-x86_64-580.126.20.run \
  "https://us.download.nvidia.com/tesla/580.126.20/NVIDIA-Linux-x86_64-580.126.20.run"
chmod +x /root/NVIDIA-Linux-x86_64-580.126.20.run

# 安装（--dkms 支持内核更新自动重编译，--no-opengl-files 避免覆盖系统 GL 库）
/root/NVIDIA-Linux-x86_64-580.126.20.run --silent --dkms --no-opengl-files

# 验证
nvidia-smi
# 期望看到: Driver Version: 580.126.20, Tesla P4
```

安装器会自动：
- 创建正确的符号链接（`.so` → `.so.1` → `.so.580.126.20`）
- 设置 `root:root` 644 权限
- 执行 `ldconfig` 注册库
- 通过 DKMS 注册内核模块

---

## 6. 安装 nvidia-container-toolkit

```bash
# 添加 NVIDIA 官方 apt 源
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
  | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
  | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
  | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# 安装
apt-get update && apt-get install -y nvidia-container-toolkit

# 验证
nvidia-container-cli info
# 期望看到: Device Index: 0, Model: Tesla P4
```

---

## 7. 配置 Docker GPU 支持

```bash
# 配置 Docker runtime（设置 nvidia 为默认 runtime）
nvidia-ctk runtime configure --runtime=docker --set-as-default

# 生成 CDI spec
nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml

# 重启 Docker
systemctl restart docker

# 验证两种调用方式
docker run --rm --gpus all ubuntu:22.04 nvidia-smi --query-gpu=name --format=csv,noheader
docker run --rm --runtime=nvidia -e NVIDIA_VISIBLE_DEVICES=all ubuntu:22.04 nvidia-smi --query-gpu=name --format=csv,noheader
```

安装后 `/etc/docker/daemon.json` 会包含：

```json
{
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "args": [],
            "path": "nvidia-container-runtime"
        }
    }
}
```

---

## 8. 配置系统参数

### 8.1 开机自动加载内核模块

```bash
cat > /etc/modules-load.d/nvidia.conf << 'EOF'
nvidia
nvidia-uvm
nvidia-modeset
nvidia-drm
EOF
```

### 8.2 启用 GPU Persistence Mode

```bash
nvidia-smi -pm 1
```

### 8.3 禁用 PCIe ASPM（防止 Xid 79 掉卡）

Tesla P4 在 PCIe 省电模式下可能从总线脱落（Xid 79: GPU has fallen off the bus）。

```bash
# 编辑 GRUB 配置
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="pcie_aspm=off /' /etc/default/grub
update-grub
```

修改后需重启生效。验证：

```bash
cat /proc/cmdline | grep pcie_aspm
# 期望包含: pcie_aspm=off
```

### 8.4 验证 PCIe 链路速度

```bash
nvidia-smi --query-gpu=pcie.link.gen.current,pcie.link.width.current --format=csv
# 期望: 3, 16 （即 Gen3 x16）
```

如果显示 `1, 16`（Gen1 降级），检查：
- BIOS 中 PCIe 槽速度设置（改为 Auto 或 Gen3）
- GPU 是否完全插紧
- 是否使用了转接卡

---

## 9. GPU 风扇自动调速

Tesla P4 是被动散热设计，依赖机箱风道。在 NAS 机箱中需要外加风扇。

### 9.1 前置：加载风扇控制芯片驱动

B360i 主板使用 ITE IT8772E Super I/O 芯片：

```bash
modprobe it87
sensors | grep fan
```

### 9.2 安装调速脚本

将 `gpu-fan-control.sh` 放置到 `/usr/local/bin/`：

```bash
#!/bin/bash
HWMON_PATH=""
for d in /sys/class/hwmon/hwmon*/; do
  if [ "$(cat ${d}name 2>/dev/null)" = "it8772" ]; then
    HWMON_PATH="$d"
    break
  fi
done

if [ -z "$HWMON_PATH" ]; then
  echo "ERROR: IT8772 hwmon not found"
  exit 1
fi

PWM_FILE="${HWMON_PATH}pwm3"
ENABLE_FILE="${HWMON_PATH}pwm3_enable"
FAN_FILE="${HWMON_PATH}fan3_input"
MIN_PWM=50

get_gpu_temp() {
  nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader 2>/dev/null
}

temp_to_pwm() {
  local temp=$1
  if   [ "$temp" -lt 40 ]; then echo $MIN_PWM
  elif [ "$temp" -lt 50 ]; then echo 76
  elif [ "$temp" -lt 60 ]; then echo 128
  elif [ "$temp" -lt 70 ]; then echo 178
  elif [ "$temp" -lt 80 ]; then echo 230
  else                          echo 255
  fi
}

echo 1 > "$ENABLE_FILE" 2>/dev/null

PREV_PWM=0
while true; do
  TEMP=$(get_gpu_temp)
  if [ -z "$TEMP" ]; then
    echo 255 > "$PWM_FILE" 2>/dev/null
    sleep 10
    continue
  fi
  TARGET_PWM=$(temp_to_pwm "$TEMP")
  if [ "$TARGET_PWM" != "$PREV_PWM" ]; then
    echo "$TARGET_PWM" > "$PWM_FILE" 2>/dev/null
    RPM=$(cat "$FAN_FILE" 2>/dev/null)
    logger -t gpu-fan "GPU: ${TEMP}C PWM: ${TARGET_PWM}/255 Fan: ${RPM}RPM"
    PREV_PWM=$TARGET_PWM
  fi
  sleep 5
done
```

温度-转速对照表：

| GPU 温度 | PWM | 风扇速度 |
|---|---|---|
| < 40°C | 50/255 | ~20% |
| 40-50°C | 76/255 | ~30% |
| 50-60°C | 128/255 | ~50% |
| 60-70°C | 178/255 | ~70% |
| 70-80°C | 230/255 | ~90% |
| > 80°C | 255/255 | 100% |
| GPU 不可用 | 255/255 | 100%（安全模式） |

### 9.3 配置 systemd 服务

`/etc/systemd/system/gpu-fan-control.service`：

```ini
[Unit]
Description=GPU Fan Auto-Control for Tesla P4
After=nvidia-persistenced.service
Wants=nvidia-persistenced.service

[Service]
Type=simple
ExecStartPre=/sbin/modprobe it87
ExecStart=/usr/local/bin/gpu-fan-control.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
chmod +x /usr/local/bin/gpu-fan-control.sh
systemctl daemon-reload
systemctl enable gpu-fan-control.service
systemctl start gpu-fan-control.service
```

**注意**：`pwm3` / `fan3` 对应的物理风扇通道取决于主板接线。安装前需用 `sensors` 确认哪个 fan 通道连接了 GPU 风扇。

---

## 10. 验证清单

```bash
# 1. 驱动加载
nvidia-smi --query-gpu=driver_version,name,temperature.gpu,pcie.link.gen.current --format=csv

# 2. Plex 用户访问
su -s /bin/bash plex -c "nvidia-smi --query-gpu=name --format=csv,noheader"

# 3. Emby 用户访问
su -s /bin/bash EmbyServer -c "nvidia-smi --query-gpu=name --format=csv,noheader"

# 4. Docker --gpus all
docker run --rm --gpus all ubuntu:22.04 nvidia-smi --query-gpu=name --format=csv,noheader

# 5. Docker --runtime=nvidia
docker run --rm --runtime=nvidia -e NVIDIA_VISIBLE_DEVICES=all ubuntu:22.04 nvidia-smi --query-gpu=name --format=csv,noheader

# 6. 符号链接正确性
ls -la /usr/lib/x86_64-linux-gnu/libcuda.so
# 期望: lrwxrwxrwx root root libcuda.so -> libcuda.so.1

# 7. PCIe ASPM
cat /proc/cmdline | grep pcie_aspm=off

# 8. Persistence Mode
nvidia-smi --query-gpu=persistence_mode --format=csv,noheader
# 期望: Enabled

# 9. 风扇调速
systemctl status gpu-fan-control.service
```

---

## 11. 故障排查

### Xid 79: GPU has fallen off the bus

```bash
dmesg -T | grep -i "Xid\|fallen off"
```

常见原因及处理：

| 原因 | 排查方法 | 解决 |
|---|---|---|
| PCIe ASPM 未禁用 | `cat /proc/cmdline` 检查 `pcie_aspm=off` | 添加内核参数 |
| 散热不足 | `nvidia-smi -l 1` 观察温度 | 加装风扇，确认调速脚本运行 |
| PCIe 接触不良 | 检查 `pcie.link.gen.current`，降级到 1 说明异常 | 重新插拔 GPU |
| PCIe 链路降级 | `nvidia-smi --query-gpu=pcie.link.gen.current --format=csv` | BIOS 设置 PCIe 为 Auto/Gen3 |

### Docker GPU 不可用

```bash
# 检查 nvidia-container-cli
nvidia-container-cli info

# 重新生成 CDI
nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
systemctl restart docker
```

### 飞牛资源管理不显示 GPU

重启 `resmon_service`：

```bash
kill $(pidof resmon_service)
# FnOS 会自动重启该服务
```

如仍不显示，确认 `nvidia-driver-lib-trim` 包状态：

```bash
dpkg -l | grep nvidia-driver-lib-trim
```

该包提供飞牛 Web UI 的 GPU 监控集成。

---

## 12. FPK 打包要点

### 包含文件清单

| 文件 | 用途 |
|---|---|
| `NVIDIA-Linux-x86_64-580.126.20.run` | NVIDIA 官方驱动安装器 |
| `/usr/local/bin/gpu-fan-control.sh` | GPU 风扇调速脚本 |
| `/etc/systemd/system/gpu-fan-control.service` | 调速服务单元 |
| `/etc/modules-load.d/nvidia.conf` | 开机自动加载模块配置 |

### 安装脚本要点 (post-install)

```bash
#!/bin/bash
set -e

# 1. 安装驱动
/path/to/NVIDIA-Linux-x86_64-580.126.20.run --silent --dkms --no-opengl-files

# 2. 安装 nvidia-container-toolkit（如果 Docker 存在）
if command -v docker &>/dev/null; then
  curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
    | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
  curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
    | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
    | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
  apt-get update -qq && apt-get install -y nvidia-container-toolkit
  nvidia-ctk runtime configure --runtime=docker --set-as-default
  nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
  systemctl restart docker
fi

# 3. 系统配置
echo -e "nvidia\nnvidia-uvm\nnvidia-modeset\nnvidia-drm" > /etc/modules-load.d/nvidia.conf
nvidia-smi -pm 1

# 4. PCIe ASPM（如果未配置）
if ! grep -q "pcie_aspm=off" /proc/cmdline; then
  sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="pcie_aspm=off /' /etc/default/grub
  update-grub
  echo "WARNING: pcie_aspm=off added, reboot required"
fi

# 5. 风扇调速（可选，仅在检测到 IT8772E 时启用）
if modprobe it87 2>/dev/null && grep -q it8772 /sys/class/hwmon/hwmon*/name 2>/dev/null; then
  cp gpu-fan-control.sh /usr/local/bin/
  chmod +x /usr/local/bin/gpu-fan-control.sh
  cp gpu-fan-control.service /etc/systemd/system/
  systemctl daemon-reload
  systemctl enable --now gpu-fan-control.service
fi
```

### 卸载脚本要点 (pre-remove)

```bash
#!/bin/bash
# 停止风扇调速
systemctl disable --now gpu-fan-control.service 2>/dev/null
rm -f /etc/systemd/system/gpu-fan-control.service
rm -f /usr/local/bin/gpu-fan-control.sh

# 卸载驱动
/usr/bin/nvidia-uninstall --silent 2>/dev/null

# 清理配置
rm -f /etc/modules-load.d/nvidia.conf
rm -f /etc/cdi/nvidia.yaml
rm -f /etc/apt/sources.list.d/nvidia-container-toolkit.list

# 恢复 GRUB（移除 pcie_aspm=off）
sed -i 's/pcie_aspm=off //' /etc/default/grub
update-grub

ldconfig
```

### 注意事项

- FnOS 内核版本更新时，DKMS 会自动重编译 NVIDIA 内核模块，但需确认新内核有对应的 `linux-headers`
- 该 FPK 不应与商店的 `Nvidia-Driver` 包共存
- 风扇调速脚本中的 `pwm3` 通道需要根据实际主板接线调整
- 驱动安装器体积约 380MB，打包时考虑是否内嵌或在线下载
