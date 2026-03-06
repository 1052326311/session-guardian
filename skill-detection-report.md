# Session Guardian - Skill Detection Report

**Generated**: Fri Mar  6 14:35:45 CST 2026

## Detected Skills

- daily-session-backup
- drawthings
- pdf-generator
- security-audit-toolkit
- self-improving-agent
- session-guardian
- yolo-local

## Feature Overlap Analysis

⚠️ Feature overlap detected. Session Guardian auto-configured to avoid duplication:

- **Error/Learning Extraction**: Delegated to `self-improving-agent`

## Optimized Configuration

Session Guardian has been configured to complement existing skills:

### Integration with self-improving-agent

**Workflow**:
1. self-improving-agent records errors and learnings in real-time (lightweight)
2. Session Guardian reads SI records during daily summary
3. Session Guardian extracts knowledge to MEMORY.md
4. Avoid duplicate analysis

**Token Savings**: ~65% (from ~30k to ~10.5k tokens/day)

**Disabled Features**:
- Error logging (delegated to SI)
- Learning records (delegated to SI)
- User corrections tracking (delegated to SI)
- Best practices extraction (delegated to SI)

**Enabled Features**:
- Session backup (unique to SG)
- Collaboration tracking (unique to SG)
- Health check (unique to SG)
- Daily summary (reads SI records)


## Recommendations

1. **Review the configuration**: Check `config.json` to ensure it matches your needs
2. **Test the integration**: Run for 1 week and monitor token consumption
3. **Adjust if needed**: You can manually enable/disable features in `config.json`
4. **Re-run detection**: Run `bash scripts/detect-skills.sh` anytime to re-detect

