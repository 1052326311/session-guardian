# Session Guardian 🛡️

**对话守护者** - 为 OpenClaw 提供企业级对话备份、恢复与项目管理能力

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/cyber-axin/session-guardian)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-0.9.0+-orange.svg)](https://openclaw.ai)

---

## 🚀 核心特性

基于 Lobster Studio 多智能体军团协作的实战经验，提供五大核心能力：

1. **计划文件机制** 📋 - 复杂任务状态管理
2. **Session 隔离规则** 🔒 - 防止跨 session/跨渠道混淆
3. **GatewayRestart 强制恢复** 🔄 - 自动恢复未完成任务

---

## 🚀 快速开始

### 安装

```bash
# 从 ClawHub 安装（推荐）
clawhub install session-guardian

# 或从 GitHub 安装
git clone https://github.com/cyber-axin/session-guardian.git ~/.openclaw/workspace/skills/session-guardian
```

### 一键部署

```bash
cd ~/.openclaw/workspace/skills/session-guardian
bash scripts/install.sh
```

### 验证安装

```bash
# 查看系统 crontab
crontab -l | grep session-guardian

# 查看 OpenClaw cron
openclaw cron list

# 运行健康检查
bash scripts/health-check.sh
```

---

## 📦 功能特性

### 五层防护体系

1. **增量备份**（每5分钟）- 最多丢失5分钟数据
2. **快照**（每小时）- 可恢复到任意时刻
3. **智能总结**（每日）- AI 提取关键对话、决策、成果
4. **健康检查**（每6小时）- 自动清理、修复配置、恢复任务
5. **项目管理**（v2.0 新增）- 计划文件 + Session 隔离 + GatewayRestart 恢复

### 核心优势

- ✅ **零 Token 成本** - 备份和快照是纯脚本，不调用 LLM
- ✅ **不影响主对话** - 使用系统 crontab，完全独立运行
- ✅ **自动清理** - 智能管理磁盘空间，不会无限增长
- ✅ **一键恢复** - 提供恢复脚本，快速回滚到任意时刻
- ✅ **Session 隔离** - 防止跨 session/跨渠道混淆
- ✅ **任务管理** - 计划文件机制，复杂任务状态可追踪

---

## 📖 使用示例

### 计划文件管理

```bash
# 创建任务计划
bash scripts/plan-manager.sh create "开发新功能"

# 更新进度
bash scripts/plan-manager.sh update "开发新功能" "1.1"

# 查看所有任务
bash scripts/plan-manager.sh list

# 归档已完成任务
bash scripts/plan-manager.sh archive "开发新功能"
```

### Session 隔离检查

```bash
# 检查所有 agent
bash scripts/session-isolation-check.sh check

# 验证单个 agent
bash scripts/session-isolation-check.sh validate main

# 生成详细报告
bash scripts/session-isolation-check.sh report
```

### 健康检查

```bash
# 运行健康检查
bash scripts/health-check.sh

# 查看报告
cat Assets/SessionBackups/health-report-*.txt
```

---

## 📚 文档

- [完整文档](SKILL.md) - 详细功能说明和配置
- [使用示例](EXAMPLES.md) - 实战案例和常见问题
- [发布说明](RELEASE-v2.0.md) - v2.0 新增功能详解

---

## 🎯 适用场景

### 1. 多智能体协作项目
- 建设多个 agent 军团
- 任务跨越多个 session
- 需要持续追踪进度

### 2. 多渠道运营
- 同时使用 Web、钉钉、Telegram 等
- 防止跨渠道泄露
- 保护用户隐私

### 3. 长期项目管理
- 项目周期长（数周/数月）
- 需要持久化任务状态
- 防止数据丢失

---

## 🔄 从 v1.x 升级

完全向后兼容，无需修改配置。

```bash
# 更新到 v2.0
cd ~/.openclaw/workspace/skills/session-guardian
git pull origin main

# 验证升级
bash scripts/health-check.sh
```

---

## 🙏 致谢

感谢 OpenClaw 团队提供强大的 Gateway 和 Cron 机制，感谢社区贡献者的建议和反馈。

---

## 📝 更新日志

### v1.0.0 (2026-03-03)
- ✨ 五层防护体系
- ✨ 计划文件机制
- ✨ Session 隔离检查
- ✨ GatewayRestart 强制恢复
- 🔧 健康检查与自动修复
- 📝 完整文档

[查看完整更新日志](RELEASE-v1.0.md)

---

## 📞 联系方式

- **作者**：赛博阿昕 (Cyber Axin) 🦞
  - Lobster Studio 创始人
  - King（龙虾之王）- 主控 AI Agent，统筹五大智能体军团
- **GitHub**：https://github.com/cyber-axin/session-guardian
- **Email**：cyber.axin@outlook.com
- **Discord**：https://discord.com/invite/clawd

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

---

**Session Guardian v2.0** - 让你的 AI 对话永不丢失，任务状态永不混淆 🛡️
