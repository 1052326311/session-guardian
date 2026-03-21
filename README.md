<div align="center">

# 🛡️ Session Guardian

**Never lose a conversation again.**

Auto-backup, smart recovery, and health monitoring for OpenClaw sessions.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![OpenClaw Skill](https://img.shields.io/badge/OpenClaw-Skill-blue.svg)](https://github.com/openclaw/openclaw)
[![ClawHub](https://img.shields.io/badge/ClawHub-session--guardian-orange.svg)](https://clawhub.ai/1052326311/session-guardian)
[![GitHub stars](https://img.shields.io/github/stars/1052326311/session-guardian?style=social)](https://github.com/1052326311/session-guardian)

*5-min auto-backup · One-command recovery · Token overflow protection · Multi-agent support*

[Quick Start](#-quick-start) · [The Problem](#-the-problem) · [How It Works](#-how-it-works) · [中文说明](#-中文说明)

</div>

---

## 😤 The Problem

```
You: (spent 2 hours working with your agent on a complex task)
Gateway: *restarts*
You: Hey, remember what we were working on?
Agent: I have no memory of our previous conversation. How can I help you?
You: ...
```

Your OpenClaw conversations live in session files. When things go wrong — and they **will** — you lose everything:

- 🔴 **Gateway restart** → entire conversation history gone
- 🔴 **Model disconnection** → mid-task context wiped out
- 🔴 **Token overflow** → session too large, agent crashes
- 🔴 **Disk issues** → session files corrupted

No built-in backup. No recovery. No warning before it's too late.

## ✅ The Fix

```
  Without Guardian                    With Guardian
┌──────────────────┐            ┌──────────────────────────┐
│ Gateway crashes  │            │  Auto-backup every 5 min │
│ → conversation   │            │  Hourly snapshots        │
│   gone forever   │            │  Health monitoring       │
│                  │            │  One-command recovery    │
│ Token overflow   │            │                          │
│ → agent frozen   │            │  Gateway crash?          │
│                  │            │  → Restore in seconds    │
│ No way back. 😱  │            │                          │
└──────────────────┘            │  Token overflow?         │
                                │  → Auto-detected + alert │
                                │                          │
                                │  Always protected. 🛡️    │
                                └──────────────────────────┘
```

## 🚀 Quick Start

### 30 seconds

```bash
# Install from ClawHub
clawhub install session-guardian

# Deploy (auto-configures all cron jobs)
cd ~/.openclaw/workspace/skills/session-guardian
bash scripts/install.sh

# Verify it's running
bash scripts/status.sh
```

### Or clone from GitHub

```bash
git clone https://github.com/1052326311/session-guardian.git \
  ~/.openclaw/workspace/skills/session-guardian
cd ~/.openclaw/workspace/skills/session-guardian
bash scripts/install.sh
```

## 🏗️ How It Works

Five layers of automatic protection:

| Layer | Schedule | What It Does |
|-------|----------|-------------|
| 📦 Incremental Backup | Every 5 min | Saves new conversations. Max 5 min of data loss. |
| 📸 Hourly Snapshot | Every hour | Full session archive. Point-in-time recovery. |
| 🏥 Health Check | Every 6 hours | Detects oversized sessions, disk issues, token overflow. |
| 📝 Smart Summary | Daily 2am | Extracts key info from conversations to MEMORY.md. |
| 🧠 Knowledge Extraction | Daily | Auto-saves best practices from all agents. |

All automatic. All in the background. Zero manual work after install.

## 📊 What You Get

| Feature | Solo Agent | Multi-Agent Team |
|---------|:---------:|:---------------:|
| Auto-backup (5 min) | ✅ | ✅ |
| Hourly snapshots | ✅ | ✅ |
| One-command recovery | ✅ | ✅ |
| Token overflow alerts | ✅ | ✅ |
| Collaboration tracking | — | ✅ |
| Knowledge extraction | ✅ | ✅ |
| Health scoring | — | ✅ |
| Task flow visualization | — | ✅ |

## 🔧 Usage

### Check Status

```bash
bash scripts/status.sh
```

Shows backup count, last backup time, cron jobs, disk usage, and overall health.

### Health Check

```bash
bash scripts/health-check.sh
```

Detects: oversized sessions, missing configs, disk space issues, gateway problems.

### Restore a Session

```bash
# List available backups
bash scripts/restore.sh list

# Restore specific agent from latest backup
bash scripts/restore.sh restore --agent main

# Dry run (see what would happen)
bash scripts/restore.sh --dry-run
```

### Collaboration (Multi-Agent)

```bash
# View collaboration health
bash scripts/collaboration-health.sh report

# Track task flow (King → Lead → Members)
bash scripts/collaboration-tracker.sh trace "task name"
```

## 📁 Where Backups Go

```
Assets/SessionBackups/
├── incremental/     # Every-5-min backups (7 days retention)
├── hourly/          # Hourly snapshots (30 days retention)
├── collaboration/   # Task flow records
└── Knowledge/       # Extracted best practices
```

All backups stay local. Nothing leaves your machine.

## ⚡ Performance

| Operation | Tokens | Storage |
|-----------|--------|---------|
| Incremental backup | ~100/run | ~10KB/session/day |
| Hourly snapshot | ~500/run | ~100KB/session/day |
| Health check | ~200/run | ~2KB/report |
| Daily summary | ~5k/run | ~5KB/day |
| **Total** | **~10-15k/day** | **~1-2MB/agent/month** |

## 🔒 Security

- ✅ All data stays local — no external services, no network requests
- ✅ No API keys required
- ✅ Read-only access to session files (only copies, never modifies)
- ✅ Backups excluded from git

## 🛠️ Configuration

Edit `scripts/config.sh`:

```bash
BACKUP_DIR         # Where backups go (default: Assets/SessionBackups)
INCREMENTAL_KEEP   # Days to keep incremental (default: 7)
SNAPSHOT_KEEP      # Days to keep snapshots (default: 30)
MAX_SESSION_SIZE   # Alert threshold (default: 5MB)
```

## 🔍 Troubleshooting

| Problem | Fix |
|---------|-----|
| Backups not running | `crontab -l \| grep session-guardian` |
| Agent slow/timing out | Run `health-check.sh` — likely token overflow |
| Can't restore | `restore.sh list` to see available backups |
| Disk filling up | Adjust retention in `config.sh` |

---

# 🇨🇳 中文说明

## 再也不丢对话了

你的 OpenClaw 对话存在 session 文件里。Gateway 一重启、模型一断连、token 一溢出——对话就没了。

**Session Guardian** 提供五层自动防护：

```
第1层：增量备份    → 每 5 分钟  → 保存新对话，最多丢 5 分钟
第2层：快照备份    → 每小时     → 完整 session 存档，支持回滚
第3层：健康检查    → 每 6 小时  → 提前发现问题（token 溢出、磁盘不足）
第4层：智能总结    → 每天       → 提取关键信息到 MEMORY.md
第5层：知识沉淀    → 每天       → 自动保存最佳实践
```

### 安装

```bash
# ClawHub 安装（推荐）
clawhub install session-guardian

# 或 GitHub 安装
git clone https://github.com/1052326311/session-guardian.git \
  ~/.openclaw/workspace/skills/session-guardian

# 部署（自动配置所有定时任务）
cd ~/.openclaw/workspace/skills/session-guardian
bash scripts/install.sh
```

### 你会得到

- ✅ **自动备份** — 每 5 分钟一次，最多丢 5 分钟对话
- ✅ **一键恢复** — 从任意备份点恢复 session
- ✅ **健康监控** — 在 token 溢出前预警
- ✅ **多 Agent 支持** — 保护所有 Agent，不只是 main
- ✅ **协作追踪** — 可视化任务流转（King → 团长 → 成员）
- ✅ **知识沉淀** — 自动从对话中提取最佳实践
- ✅ **极低开销** — 每天约 10-15k tokens，每月约 1-2MB/Agent

### 常用命令

```bash
bash scripts/status.sh               # 查看状态
bash scripts/health-check.sh         # 健康检查
bash scripts/restore.sh list         # 查看备份列表
bash scripts/restore.sh restore --agent main  # 恢复 session
bash scripts/collaboration-health.sh report   # 协作健康度
```

### 适用场景

| 场景 | 功能 |
|------|------|
| **个人用户** | 保护主对话不丢失，token 溢出前预警，秒级恢复 |
| **多 Agent 团队** | 保护所有 Agent，追踪协作链路，自动沉淀知识 |

### 安全性

- 所有数据本地存储，不联网，不需要 API Key
- 不修改 session 文件，只读取和复制
- 备份文件已排除 git 追踪

---

## 📜 Changelog

### v3.1.0 (2026-03-21)
- 📝 Complete SKILL.md rewrite — concise, bilingual, ClawHub-optimized
- 🐛 Fixed health-check auto-modifying agent configs (removed hardcoded model)
- 🎨 New ASCII comparison diagrams

### v2.0.0 (2026-03-05)
- ✨ Collaboration tracking (King → Lead → Members)
- ✨ Smart backup strategy per agent
- ✨ Knowledge extraction
- ✨ Collaboration health scoring

### v1.0.0 (2026-03-01)
- 🎉 Initial release — five-layer protection system

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

## ⭐ Support

If this skill saved your conversations, give it a star! ⭐

```bash
clawhub star session-guardian    # on ClawHub
```
