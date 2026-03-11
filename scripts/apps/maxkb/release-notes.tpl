自动构建的 fnOS 安装包

- 基于 [MaxKB v${VERSION}](https://github.com/1Panel-dev/MaxKB/releases/tag/v${VERSION})
- 平台: fnOS
- 默认端口: ${DEFAULT_PORT}${REVISION_NOTE}
- 默认数据目录: `${TRIM_PKGVAR}/data`

**首次使用**:
1. 首次启动需拉取 Docker 镜像，请耐心等待
2. 访问 `http://your-nas-ip:${DEFAULT_PORT}` 登录管理界面
3. 默认账号: `admin`，密码: `MaxKB@123..`
4. 建议内存 4GB 以上以获得最佳 RAG 体验

${CHANGELOG}
**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
