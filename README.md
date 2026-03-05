# Session Guardian 🛡️

企业级对话备份 + 多智能体协作管理解决方案

## 核心价值

- 🔒 **对话永不丢失** - 五层防护体系，最多丢失5分钟数据
- 🤝 **协作可追踪** - 可视化agent间的协作链路
- 📚 **知识自动沉淀** - 提取最佳实践和常见问题
- 📊 **健康度监控** - 量化评估协作质量
- 🎯 **任务可管理** - 复杂任务状态持久化

## 适用场景

✅ 企业多智能体协作（团队分工）  
✅ 个人助手团队（多专业助手）  
✅ 单agent深度使用（长期记忆）  
✅ 企业多部门协作（信息隔离）

## 快速开始

```bash
# 安装
clawhub install session-guardian

# 一键部署
cd ~/.openclaw/workspace/skills/session-guardian
bash scripts/install.sh

# 验证
openclaw cron list
```

## v2.0 新功能

### 1. 协作链路追踪 🔗
追踪任务在多个agent间的流转过程

```bash
bash scripts/collaboration-tracker.sh trace "任务名"
bash scripts/collaboration-tracker.sh graph "任务名"
```

### 2. 智能备份策略 📦
自动区分固定agent（5MB限制）和临时subagent（1MB限制）

- 固定agent：保护长期记忆，保留90天
- 临时subagent：节省空间，保留7天

### 3. 知识库沉淀 📚
自动提取最佳实践（✅标记）和常见问题（❌标记）

```bash
bash scripts/knowledge-extractor.sh extract dev-lead
bash scripts/knowledge-extractor.sh extract-all
```

### 4. 协作健康度 📊
量化评估协作质量（0-100分）

```bash
bash scripts/collaboration-health.sh report
```

## 五层防护体系

| 层级 | 频率 | 功能 | Token成本 |
|------|------|------|-----------|
| 增量备份 | 每5分钟 | 最多丢失5分钟数据 | 0 |
| 快照 | 每小时 | 可恢复到任意时刻 | 0 |
| 智能总结 | 每日 | AI提取关键内容 | ~1000 |
| 健康检查 | 每6小时 | 自动清理过大session | 0 |
| 项目管理 | 按需 | 复杂任务状态追踪 | 0 |

## 核心优势

- ✅ **零Token成本** - 备份和快照不调用LLM
- ✅ **不影响主对话** - 完全独立运行
- ✅ **自动清理** - 智能管理磁盘空间
- ✅ **一键恢复** - 快速回滚到任意时刻
- ✅ **完全向后兼容** - v1.0用户无缝升级

## 文档

完整文档请查看 [SKILL.md](./SKILL.md)

## 版本

- v2.0.0 (2026-03-05) - 多智能体协作管理
- v1.0.0 (2026-03-02) - 基础备份功能

## 作者

赛博阿昕 (Cyber Axin)

## 许可

MIT License
