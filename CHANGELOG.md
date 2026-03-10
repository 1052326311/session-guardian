# Changelog

All notable changes to Session Guardian will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.1] - 2026-03-08

### Added
- install.sh: reserveTokens自动检测，建议从50000调低到15000减少compaction频率
- SKILL.md: Multi-Agent Best Practices章节（compaction打断问题、派发规则）
- token-monitor.sh: 输出末尾增加reserveTokens配置检测和建议

### Fixed
- 定位sessions_send频繁中断根因：compaction打断长超时tool调用

## [2.2.0] - 2026-03-08

### Added
- Token预警监控 (`scripts/token-monitor.sh`): 60%黄色预警, 80%红色预警
- 智能Reset恢复 (`scripts/context-recovery.sh`): reset前自动保存上下文摘要
- 汇报精简规则: 写入所有军团AGENTS.md，减少token浪费
- config.json新增 `tokenMonitor` 和 `contextRecovery` 配置项
- config.sh新增 v2.2 Token预警配置区

### Changed
- SKILL.md 更新至 v2.2.0，新增 "What's New in v2.2" 章节

### Fixed
- 解决session overflow导致的军团abort/卡住问题（根因：无预警机制）
- 解决reset后需要手动传递大量上下文的问题（根因：无恢复机制）

## [1.0.0] - 2026-03-03

### Added
- 五层防护体系：增量备份 + 快照 + 智能总结 + 健康检查 + 项目管理
- 计划文件机制：复杂任务状态管理（`scripts/plan-manager.sh`）
- Session 隔离检查：防止跨 session/跨渠道混淆（`scripts/session-isolation-check.sh`）
- GatewayRestart 强制恢复：自动恢复未完成任务
- 健康检查：自动清理过大 session 文件（>1MB）、修复配置、恢复任务
- 增量备份：每5分钟自动备份，最多丢失5分钟数据
- 快照备份：每小时完整备份，可恢复到任意时刻
- 智能总结：每日 AI 总结，提取关键对话、决策、成果
- 一键安装脚本：自动配置 crontab 和 OpenClaw cron
- 恢复脚本：支持从增量备份、快照、每日总结恢复
- 完整文档：SKILL.md、EXAMPLES.md、RELEASE-v1.0.md
- 使用示例：实战案例和常见问题解答

### Technical Details
- 基于 Lobster Studio 多智能体军团协作的实战经验
- 零 Token 成本（备份和快照不调用 LLM）
- 完全独立运行（使用系统 crontab）
- 自动清理和磁盘空间管理
- 向后兼容（未来版本升级无需修改配置）

[1.0.0]: https://github.com/cyber-axin/session-guardian/releases/tag/v1.0.0
