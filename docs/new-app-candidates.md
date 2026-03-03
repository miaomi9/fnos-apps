# fnOS 新应用候选分析

> **生成日期**: 2026-03-02
>
> **数据来源**: selfh.st 2025 社区调查 (4,081 responses)、awesome-selfhosted、GitHub stars、Reddit r/selfhosted、V2EX / 什么值得买 / fnOS 论坛、TechHut / PerfectMediaServer 等 homelab 博客

## 现有应用 (31 款)

| 类别 | 已有应用 |
|------|---------|
| 媒体 | Plex, Emby, Jellyfin, Navidrome, Kavita, Koel, tinyMediaManager |
| 照片 | Immich |
| 下载 | qBittorrent, Gopeed, Syncthing, Transmission |
| 内容 | ANI-RSS, AutoBangumi, Audiobookshelf, MoviePilot, OpenList, KodBox, Memos |
| 系统 | Certimate, Sun-Panel, Vaultwarden, Nginx, Nginx UI, Gotify, DDNS-GO, WolGoWeb, AdGuardHome |
| 浏览器 | Firefox, Chromium |
| 应用中心 | fnOS Apps |

---

## P0 - 必做 (用户需求最强烈、ROI 最高)

### 1. Uptime Kuma — 服务监控

| 项目 | 详情 |
|------|------|
| GitHub | [louislam/uptime-kuma](https://github.com/louislam/uptime-kuma) |
| Stars | 62k+ |
| 技术栈 | Node.js / Vue |
| 架构 | amd64 + arm64 (Docker) |
| 打包方式 | Docker (推荐) 或 Node.js standalone |
| 打包难度 | 中 |
| 端口 | 3001 |

**为什么 P0**: selfh.st 2025 调查中用户最常运行的监控工具 #1。NAS 用户需要监控 Plex/Jellyfin/qBittorrent 等服务是否正常运行,并通过 Telegram/Gotify 接收告警。与现有 Gotify 形成互补。

---

### 2. Sonarr — 电视剧自动化

| 项目 | 详情 |
|------|------|
| GitHub | [Sonarr/Sonarr](https://github.com/Sonarr/Sonarr) |
| Stars | 13k+ |
| 技术栈 | C# (.NET) |
| 架构 | 原生 linux-x64 / linux-arm64 二进制 |
| 打包方式 | 原生 (类似 Kavita 的 .NET self-contained) |
| 打包难度 | 中 |
| 端口 | 8989 |

**为什么 P0**: *arr 套件核心组件,与 MoviePilot/qBittorrent 互补。中国 NAS 社区 #1 请求。原生二进制可用,无需 Docker。

---

### 3. Radarr — 电影自动化

| 项目 | 详情 |
|------|------|
| GitHub | [Radarr/Radarr](https://github.com/Radarr/Radarr) |
| Stars | 10.5k+ |
| 技术栈 | C# (.NET) |
| 架构 | 原生 linux-x64 / linux-arm64 二进制 |
| 打包方式 | 原生 (同 Sonarr) |
| 打包难度 | 中 |
| 端口 | 7878 |

**为什么 P0**: Sonarr 的电影版本,两者通常一起部署。已有 MoviePilot 但 Radarr 是国际社区标准,对非中文用户至关重要。

---

### 4. Prowlarr — 索引器管理

| 项目 | 详情 |
|------|------|
| GitHub | [Prowlarr/Prowlarr](https://github.com/Prowlarr/Prowlarr) |
| Stars | 4.5k+ |
| 技术栈 | C# (.NET) |
| 架构 | 原生 linux-x64 / linux-arm64 二进制 |
| 打包方式 | 原生 (同 Sonarr) |
| 打包难度 | 中 |
| 端口 | 9696 |

**为什么 P0**: Sonarr/Radarr 的"大脑",集中管理所有索引器并自动同步到各 *arr 应用。没有 Prowlarr,*arr 套件体验大打折扣。一个 .NET 二进制打包模式可复用到全部 *arr 应用。

---

### 5. Homepage — 应用仪表盘

| 项目 | 详情 |
|------|------|
| GitHub | [gethomepage/homepage](https://github.com/gethomepage/homepage) |
| Stars | 19k+ |
| 技术栈 | Next.js (Node.js) |
| 架构 | amd64 + arm64 (Docker) |
| 打包方式 | Docker |
| 打包难度 | 中 |
| 端口 | 3003 |

**为什么 P0**: NAS 装了 10+ 应用后,用户迫切需要一个统一入口。Homepage 支持 100+ 服务集成 (Docker, Plex, Sonarr 等),可作为 fnOS 的"应用总览"。2025 社区调查中仪表盘类 #1。

---

### 6. Stirling-PDF — PDF 工具箱

| 项目 | 详情 |
|------|------|
| GitHub | [Stirling-Tools/Stirling-PDF](https://github.com/Stirling-Tools/Stirling-PDF) |
| Stars | 45k+ |
| 技术栈 | Java (Spring Boot) |
| 架构 | amd64 + arm64 (Docker) |
| 打包方式 | Docker |
| 打包难度 | 中 |
| 端口 | 8080 |

**为什么 P0**: 2025 年增长最快的自托管工具之一 (45k stars)。合并、拆分、OCR、转换 PDF — 家庭办公刚需。所有数据在本地处理,隐私友好。

---

### 7. Lucky — 网络工具 (中国用户刚需)

| 项目 | 详情 |
|------|------|
| GitHub | [gdy666/lucky](https://github.com/gdy666/lucky) |
| Stars | 10k+ |
| 技术栈 | Go |
| 架构 | 原生 linux-amd64 / linux-arm64 二进制 |
| 打包方式 | 原生 (Go 单二进制,类似 DDNS-GO) |
| 打包难度 | 低 |
| 端口 | 16601 |

**为什么 P0**: 中国 NAS 社区 "万金油" — DDNS + 反向代理 + HTTPS 证书 + 端口转发 + IPv6 转 IPv4,一站式解决国内网络访问痛点。在 V2EX 和什么值得买 NAS 版块中被称为 "必装应用"。Go 单二进制,打包复杂度与 DDNS-GO 相同,开发成本极低。

---

## P1 - 高价值 (强需求、明显提升体验)

### 8. Paperless-ngx — 文档管理

| 项目 | 详情 |
|------|------|
| GitHub | [paperless-ngx/paperless-ngx](https://github.com/paperless-ngx/paperless-ngx) |
| Stars | 22k+ |
| 技术栈 | Python (Django) |
| 架构 | amd64 + arm64 (Docker) |
| 打包方式 | Docker (依赖 Redis + PostgreSQL/SQLite) |
| 打包难度 | 高 |
| 端口 | 8000 |

**为什么 P1**: 文档 OCR 扫描、索引、归档 — 把纸质文件数字化的 #1 工具。selfh.st 调查生产力类 Top 3。打包复杂度偏高是唯一阻力。

---

### 9. FreshRSS — RSS 阅读器

| 项目 | 详情 |
|------|------|
| GitHub | [FreshRSS/FreshRSS](https://github.com/FreshRSS/FreshRSS) |
| Stars | 10k+ |
| 技术栈 | PHP |
| 架构 | amd64 + arm64 (Docker) |
| 打包方式 | Docker (PHP + SQLite/MySQL) |
| 打包难度 | 中 |
| 端口 | 8180 |

**为什么 P1**: RSS 阅读器中最受欢迎的自托管选项。支持第三方客户端 (Google Reader API),可与 ANI-RSS 互补使用。selfh.st 调查中 RSS 类 #1。

---

### 10. Jellyseerr — 媒体请求管理

| 项目 | 详情 |
|------|------|
| GitHub | [Fallenbagel/jellyseerr](https://github.com/Fallenbagel/jellyseerr) |
| Stars | 4k+ |
| 技术栈 | TypeScript (Node.js/Next.js) |
| 架构 | amd64 + arm64 (Docker) |
| 打包方式 | Docker |
| 打包难度 | 中 |
| 端口 | 5055 |

**为什么 P1**: 家庭成员通过漂亮的 UI 请求想看的电影/剧集,自动触发 Sonarr/Radarr 下载。Jellyfin/Emby/Plex 全支持。完善 *arr 生态体验的关键一环。

---

### 11. ChineseSubFinder — 中文字幕下载

| 项目 | 详情 |
|------|------|
| GitHub | [ChineseSubFinder/ChineseSubFinder](https://github.com/ChineseSubFinder/ChineseSubFinder) |
| Stars | 5.2k+ |
| 技术栈 | Go |
| 架构 | 原生 linux-amd64 / linux-arm64 二进制 |
| 打包方式 | 原生 (Go 单二进制) |
| 打包难度 | 低 |
| 端口 | 19035 |

**为什么 P1**: 中文 NAS 用户的刚需 — 自动从射手网、字幕组等源下载匹配的中文字幕并嵌入 Emby/Jellyfin/Plex。Go 单二进制打包成本极低。

---

### 12. SmartDNS — DNS 加速

| 项目 | 详情 |
|------|------|
| GitHub | [pymumu/smartdns](https://github.com/pymumu/smartdns) |
| Stars | 8.2k+ |
| 技术栈 | C |
| 架构 | 原生多架构二进制 |
| 打包方式 | 原生 |
| 打包难度 | 低 |
| 端口 | 6053 (DNS), 6580 (Web UI) |

**为什么 P1**: 中国用户常与 AdGuardHome 搭配使用 ("DNS 叠加"),从多个上游 DNS 取最快结果。打包简单,与现有 AdGuardHome 形成强互补。

---

### 13. Bazarr — 字幕自动化

| 项目 | 详情 |
|------|------|
| GitHub | [morpheus65535/bazarr](https://github.com/morpheus65535/bazarr) |
| Stars | 5.2k+ |
| 技术栈 | Python |
| 架构 | amd64 + arm64 (Docker 或 standalone Python) |
| 打包方式 | Docker (推荐) |
| 打包难度 | 高 (Python 依赖链复杂) |
| 端口 | 6767 |

**为什么 P1**: 与 Sonarr/Radarr 深度集成,自动为所有影片匹配下载字幕。国际用户和中国用户都需要 (可配合 ChineseSubFinder)。

---

### 14. Homarr — 智能仪表盘

| 项目 | 详情 |
|------|------|
| GitHub | [homarr-labs/homarr](https://github.com/homarr-labs/homarr) |
| Stars | 12k+ |
| 技术栈 | Next.js (Node.js) |
| 架构 | amd64 + arm64 (Docker) |
| 打包方式 | Docker |
| 打包难度 | 中 |
| 端口 | 7575 |

**为什么 P1**: 如果 Homepage 太 "YAML 配置向",Homarr 提供更友好的可视化编辑体验。深度集成 *arr 套件状态展示。Homepage 的替代选项。

---

### 15. FileBrowser — 网页文件管理器

| 项目 | 详情 |
|------|------|
| GitHub | [filebrowser/filebrowser](https://github.com/filebrowser/filebrowser) |
| Stars | 25k+ |
| 技术栈 | Go |
| 架构 | 原生 linux-amd64 / linux-arm64 二进制 |
| 打包方式 | 原生 (Go 单二进制) |
| 打包难度 | 低 |
| 端口 | 8082 |

**为什么 P1**: 轻量级 Web 文件管理器,支持上传/下载/分享/编辑。与 fnOS 自带文件管理互补,适合外部分享场景。Go 单二进制,打包成本极低。

---

## P2 - 有价值 (锦上添花、特定用户群)

### 16. Mealie — 食谱管理

| 项目 | 详情 |
|------|------|
| GitHub | [mealie-recipes/mealie](https://github.com/mealie-recipes/mealie) |
| Stars | 7k+ |
| 技术栈 | Python / Vue |
| 架构 | amd64 + arm64 (Docker) |
| 打包方式 | Docker |
| 打包难度 | 中 |
| 端口 | 9925 |

**理由**: selfh.st 调查中食谱类 #1,适合家庭用户。

---

### 17. Linkwarden — 书签管理

| 项目 | 详情 |
|------|------|
| GitHub | [linkwarden/linkwarden](https://github.com/linkwarden/linkwarden) |
| Stars | 10k+ |
| 技术栈 | Next.js / Prisma |
| 架构 | amd64 + arm64 (Docker) |
| 打包方式 | Docker (需 PostgreSQL) |
| 打包难度 | 高 |
| 端口 | 3050 |

**理由**: 带网页存档的书签管理器,2025 年热门新应用。

---

### 18. Lidarr — 音乐自动化

| 项目 | 详情 |
|------|------|
| GitHub | [Lidarr/Lidarr](https://github.com/Lidarr/Lidarr) |
| Stars | 3.8k+ |
| 技术栈 | C# (.NET) |
| 架构 | 原生 linux-x64 / linux-arm64 二进制 |
| 打包方式 | 原生 (同 Sonarr) |
| 打包难度 | 中 |
| 端口 | 8686 |

**理由**: 音乐版 Sonarr。与 Navidrome 搭配使用。需求不如 Sonarr/Radarr 高但稳定。

---

### 19. Readarr — 电子书自动化

| 项目 | 详情 |
|------|------|
| GitHub | [Readarr/Readarr](https://github.com/Readarr/Readarr) |
| Stars | 2.5k+ |
| 技术栈 | C# (.NET) |
| 架构 | 原生 linux-x64 / linux-arm64 二进制 |
| 打包方式 | 原生 (同 Sonarr) |
| 打包难度 | 中 |
| 端口 | 8787 |

**理由**: 电子书版 Sonarr。与 Kavita/Audiobookshelf 搭配。

---

### 20. Wiki.js — 知识库

| 项目 | 详情 |
|------|------|
| GitHub | [requarks/wiki](https://github.com/requarks/wiki) |
| Stars | 24k+ |
| 技术栈 | Node.js (Vue) |
| 架构 | amd64 + arm64 (Docker) |
| 打包方式 | Docker (需 PostgreSQL) |
| 打包难度 | 高 |
| 端口 | 3100 |

**理由**: 最受欢迎的自托管 Wiki。适合技术用户搭建个人/家庭知识库。

---

### 21. MosDNS — DNS 分流

| 项目 | 详情 |
|------|------|
| GitHub | [IrineSistworking/mosdns](https://github.com/IrineSistworking/mosdns) |
| Stars | 6.8k+ |
| 技术栈 | Go |
| 架构 | 原生多架构二进制 |
| 打包方式 | 原生 (Go 单二进制) |
| 打包难度 | 低 |
| 端口 | 5353 |

**理由**: 中国用户 DNS 分流核心工具,国内域名走国内 DNS、国外走加密 DNS。与 AdGuardHome + SmartDNS 形成 DNS 三件套。

---

### 22. Actual Budget — 个人记账

| 项目 | 详情 |
|------|------|
| GitHub | [actualbudget/actual](https://github.com/actualbudget/actual) |
| Stars | 13k+ |
| 技术栈 | Node.js |
| 架构 | amd64 + arm64 (Docker) |
| 打包方式 | Docker |
| 打包难度 | 中 |
| 端口 | 5006 |

**理由**: 本地优先的个人财务管理,selfh.st 调查财务类 #1。

---

### 23. Miniflux — 极简 RSS 阅读器

| 项目 | 详情 |
|------|------|
| GitHub | [miniflux/v2](https://github.com/miniflux/v2) |
| Stars | 11k+ |
| 技术栈 | Go |
| 架构 | 原生 linux-amd64 / linux-arm64 二进制 |
| 打包方式 | 原生 (Go 单二进制,需 PostgreSQL) |
| 打包难度 | 中 |
| 端口 | 8190 |

**理由**: FreshRSS 的极简替代品。Go 单二进制,性能更优。

---

### 24. Beszel — 轻量服务器监控

| 项目 | 详情 |
|------|------|
| GitHub | [henrygd/beszel](https://github.com/henrygd/beszel) |
| Stars | 5k+ |
| 技术栈 | Go |
| 架构 | 原生 linux-amd64 / linux-arm64 二进制 |
| 打包方式 | 原生 (Go 单二进制) |
| 打包难度 | 低 |
| 端口 | 8090 (注意与 Certimate 冲突,需改) |

**理由**: 2025/2026 年增长最快的监控工具,比 Uptime Kuma 更轻量,专注服务器资源 + Docker 容器监控。

---

### 25. PhotoPrism — AI 照片管理

| 项目 | 详情 |
|------|------|
| GitHub | [photoprism/photoprism](https://github.com/photoprism/photoprism) |
| Stars | 33k+ |
| 技术栈 | Go / TensorFlow |
| 架构 | amd64 + arm64 (Docker) |
| 打包方式 | Docker |
| 打包难度 | 高 (AI 模型体积大) |
| 端口 | 2342 |

**理由**: 已有 Immich,但 PhotoPrism 更成熟稳定。适合不想频繁更新的用户。两者市场定位有差异。

---

## P3 - 长期考虑 (需求存在但优先级低)

| # | 应用 | Stars | 技术栈 | 打包难度 | 理由 |
|---|------|-------|--------|---------|------|
| 26 | **BookStack** (Wiki) | 16k+ | PHP | 中 | Wiki.js 替代品,PHP 更易部署 |
| 27 | **Firefly III** (财务) | 16k+ | PHP | 中 | 更完整的财务管理,功能比 Actual Budget 丰富 |
| 28 | **n8n** (自动化) | 45k+ | Node.js | 高 | 工作流自动化,类似 Zapier |
| 29 | **Authentik** (SSO) | 12k+ | Python/Go | 高 | 身份认证 SSO/MFA,适合多应用用户 |
| 30 | **Changedetection.io** (网页监控) | 18k+ | Python | 中 | 监控网页变化,适合比价/抢购 |
| 31 | **Home Assistant** (智能家居) | 73k+ | Python | 极高 | 用户量巨大但包太复杂,更适合独立设备运行 |
| 32 | **Ollama** (本地 AI) | 150k+ | Go/C++ | 高 | 本地大模型推理,2025/2026 热门趋势 |
| 33 | **Open WebUI** (AI 界面) | 106k+ | Node.js/Py | 高 | Ollama 前端,需搭配使用 |
| 34 | **Nextcloud** (全家桶) | 27k+ | PHP | 极高 | 功能太庞大,资源占用高,NAS 上体验一般 |
| 35 | **FlareSolverr** (CF 绕过) | 8k+ | Python/Chromium | 极高 | Prowlarr 辅助工具,需要无头浏览器 |
| 36 | **Portainer** (Docker 管理) | 31k+ | Go | 中 | Docker 管理面板,但 fnOS 已有原生 Docker UI |
| 37 | **Tailscale/Headscale** (VPN) | 18k/23k | Go | 高 | 需要系统级网络权限,与 NAS OS 可能冲突 |
| 38 | **1Panel** (服务器面板) | 24k+ | Go/Vue | 高 | 定位与 fnOS 自身管理界面重叠 |
| 39 | **Tandoor Recipes** (食谱) | 7k+ | Python | 高 | Mealie 替代品,功能更多但更重 |
| 40 | **Overseerr/Seerr** (请求管理) | 6k+ | Node.js | 中 | Jellyseerr 合并后的统一版本,关注发展 |

---

## 打包复杂度速查

基于 fnOS 现有打包经验,各技术栈的打包难度评估:

| 技术栈 | 难度 | 参考已有应用 | 说明 |
|--------|------|-------------|------|
| **Go 单二进制** | 低 | DDNS-GO, Syncthing, Navidrome | 下载 + 改名,最简单 |
| **Rust 单二进制** | 低 | Vaultwarden | 同 Go |
| **.NET self-contained** | 中 | Kavita | 无需外部运行时,包体积 ~100MB |
| **Java (含 JRE)** | 中 | tinyMediaManager, ANI-RSS | 需捆绑 JRE |
| **Node.js** | 中-高 | — | 需捆绑 Node 运行时或 Docker |
| **Python** | 高 | MoviePilot | 需 venv + 依赖管理 |
| **Docker Compose** | 中 | Immich, KodBox | 依赖 fnOS Docker 支持 |
| **PHP** | 中 | — | 需 PHP-FPM + Web Server |

---

## 推荐实施路线

### 第一批 (打包简单、需求最强)

这些应用打包复杂度低,用户需求高,可快速上线:

| 应用 | 技术 | 打包难度 | 预计工时 |
|------|------|---------|---------|
| **Lucky** | Go 单二进制 | 低 | 1-2 天 |
| **ChineseSubFinder** | Go 单二进制 | 低 | 1-2 天 |
| **SmartDNS** | C 二进制 | 低 | 1-2 天 |
| **FileBrowser** | Go 单二进制 | 低 | 1-2 天 |
| **Beszel** | Go 单二进制 | 低 | 1-2 天 |

### 第二批 (*arr 生态一次性上线)

同一 .NET 打包模式可复用,建议一起发布形成完整生态:

| 应用 | 技术 | 打包难度 | 预计工时 |
|------|------|---------|---------|
| **Prowlarr** | .NET | 中 | 2-3 天 (首个建立模板) |
| **Sonarr** | .NET | 中 | 1 天 (复用模板) |
| **Radarr** | .NET | 中 | 1 天 (复用模板) |
| **Lidarr** | .NET | 中 | 1 天 (复用模板) |
| **Readarr** | .NET | 中 | 1 天 (复用模板) |

### 第三批 (Docker 应用、中等投入)

| 应用 | 技术 | 打包难度 | 预计工时 |
|------|------|---------|---------|
| **Uptime Kuma** | Docker | 中 | 2-3 天 |
| **Homepage** | Docker | 中 | 2-3 天 |
| **Stirling-PDF** | Docker | 中 | 2-3 天 |
| **Jellyseerr** | Docker | 中 | 2-3 天 |
| **FreshRSS** | Docker | 中 | 2-3 天 |
| **Homarr** | Docker | 中 | 2-3 天 |

### 第四批 (复杂应用、高投入高回报)

| 应用 | 技术 | 打包难度 | 预计工时 |
|------|------|---------|---------|
| **Paperless-ngx** | Docker (多容器) | 高 | 3-5 天 |
| **Bazarr** | Python/Docker | 高 | 3-5 天 |
| **Mealie** | Docker | 中 | 2-3 天 |

---

## 注意事项

1. **端口冲突**: Beszel 默认 8090 与 Certimate 冲突; Stirling-PDF 默认 8080 可能冲突。打包时需调整默认端口。
2. ***arr 套件联动**: Sonarr/Radarr/Prowlarr 建议同时上线,否则单独一个 app 体验不完整。
3. **中国特色优先**: Lucky、ChineseSubFinder、SmartDNS 对 fnOS 核心用户群 (中国 NAS 用户) 具有独特吸引力,应优先于国际热门应用。
4. **Docker vs 原生**: 尽量选择原生二进制打包 (Go/Rust/.NET),Docker 应用虽然更通用但增加了 fnOS 对 Docker 的依赖。
5. **长期趋势**: AI 本地推理 (Ollama + Open WebUI) 是 2025/2026 最大趋势,但资源要求高 (GPU/大内存),对 NAS 硬件有门槛。建议观望至用户硬件普遍升级后再考虑。
