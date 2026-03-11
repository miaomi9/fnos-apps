# MaxKB for fnOS

企业级智能体平台，支持 RAG 知识库、工作流引擎和多模型对话。

- **上游项目**: [1Panel-dev/MaxKB](https://github.com/1Panel-dev/MaxKB)
- **打包模式**: Docker 容器（内置 PostgreSQL + pgvector + Redis）
- **默认端口**: 8083
- **默认账号**: admin / MaxKB@123..

## 特性

- RAG 管道：支持文档上传、自动分段、向量化，减少大模型幻觉
- 工作流引擎：可编排 AI 流程，支持 MCP 工具调用
- 无缝集成：零代码快速集成到第三方业务系统
- 多模型支持：兼容 DeepSeek、Llama、Qwen、OpenAI、Claude 等

## 本地构建

```bash
cd apps/maxkb
./update_maxkb.sh              # 最新版本，自动检测架构
./update_maxkb.sh 2.6.1        # 指定版本
./update_maxkb.sh --arch x86   # 指定架构
```

构建产物输出到 `dist/` 目录。

## 注意事项

- 首次启动需拉取 Docker 镜像（约 2GB），请耐心等待
- 建议分配 4GB 以上内存以获得最佳体验
- 数据存储在 `${TRIM_PKGVAR}/data` 目录，包含数据库和向量索引
