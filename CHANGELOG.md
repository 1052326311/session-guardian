# Session Guardian 更新日志

所有重要的更改都会记录在这个文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [1.1.0] - 2026-03-03

### 新增
- ✨ **健康检查功能** (`health-check.sh`)：自动检测并修复 session 和配置问题
  - Session 文件大小监控：自动清理 >1MB 的过大文件
  - Agent 配置完整性检查：自动修复缺失的 defaultModel
  - 磁盘空间监控：提前预警空间不足（< 1GB）
  - Gateway 状态检查：确保 Gateway 正常运行
  - 自动告警推送：发现问题立即通知
- ✨ 新增配置项：`SESSION_SIZE_LIMIT_MB`、`DEFAULT_MODEL`、`HEALTH_CHECK_INTERVAL`
- ✨ 健康报告生成：自动生成检查报告和告警信息

### 修复
- 🐛 修复了 session 文件过大导致的上下文爆炸问题（4-8MB → <1MB）
- 🐛 修复了 agent 配置缺失导致的超时问题
- 🐛 修复了长时间运行的 session 积累状态问题

### 改进
- 📝 更新了 SKILL.md，增加第4层防护的文档
- 📝 增加了真实问题案例和解决方案说明

## [1.0.0] - 2026-03-02

### 新增
- ✨ 三层防护体系（增量备份 + 快照 + 智能总结）
- ✨ 一键安装脚本（`install.sh`）
- ✨ 恢复脚本（`restore.sh`），支持多种恢复场景
- ✨ 状态检查脚本（`status.sh`），实时监控备份状态
- ✨ 配置文件（`config.sh`），所有参数可自定义
- ✨ 增量备份（每5分钟），使用 rsync 增量同步
- ✨ 快照备份（每小时），压缩存储，自动清理
- ✨ 智能总结（每日），使用 LLM 生成结构化总结
- ✨ 文件锁机制，避免并发备份
- ✨ 健康检查，自动告警
- ✨ 完整文档（SKILL.md + README.md）
- ✨ MIT 许可证

### 特性
- 🎯 零 Token 成本（备份和快照是纯脚本）
- 🎯 不影响主对话（使用系统 crontab）
- 🎯 自动清理（智能管理磁盘空间）
- 🎯 一键恢复（支持多种恢复场景）
- 🎯 跨平台（macOS、Linux、Windows WSL）

### 已知问题
- macOS 不支持 `flock`，使用文件锁替代
- 需要手动配置 OpenClaw cron 的推送目标

### 计划功能
- [ ] 远程备份（rsync / rclone）
- [ ] 备份加密（GPG）
- [ ] 按军团分类总结
- [ ] 导出为 PDF
- [ ] Web UI 管理界面
- [ ] 备份完整性验证
- [ ] 增量恢复（只恢复变化的部分）
- [ ] 多版本管理（类似 Git）

## [未来版本]

### 计划中
- 远程备份到云存储（S3 / OSS / Google Drive）
- 备份加密（保护敏感对话）
- Web UI 管理界面（可视化管理备份）
- 备份完整性验证（自动检测损坏）
- 增量恢复（只恢复变化的部分）
- 多版本管理（类似 Git 的版本控制）
- 按军团分类总结（分别生成各军团的总结）
- 导出为 PDF（用于分享和存档）
- 告警集成（钉钉 / Telegram / Email）
- 性能优化（多线程压缩、硬链接）

---

[1.0.0]: https://github.com/cyber-axin/session-guardian/releases/tag/v1.0.0
