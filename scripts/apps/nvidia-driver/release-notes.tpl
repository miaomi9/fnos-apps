自动构建的 fnOS 安装包

- 基于 [NVIDIA R580 LTS 驱动 v${VERSION}](https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-${VERSION}/index.html)
- 包含 nvidia-container-toolkit（Docker GPU 直通支持）
- 仅支持 x86_64 架构
- 安装类型: 系统分区（root）${REVISION_NOTE}

${CHANGELOG}

**安装前提**:
- 内核头文件: \`apt install linux-headers-\$(uname -r)\`
- 编译工具: \`apt install build-essential\`

**安装后验证**:
\`\`\`bash
nvidia-smi
docker run --rm --gpus all ubuntu:22.04 nvidia-smi
\`\`\`

**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
