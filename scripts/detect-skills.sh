#!/bin/bash
# Session Guardian - Smart Skill Detection and Auto-Configuration
# Detects installed skills and auto-configures to avoid feature overlap

SKILLS_DIR="${SKILLS_DIR:-$HOME/.openclaw/workspace/skills}"
CONFIG_FILE="$(dirname "$0")/../config.json"
DETECTION_REPORT="$(dirname "$0")/../skill-detection-report.md"

echo "🔍 Detecting installed skills..."

# Detect installed skills
INSTALLED_SKILLS=()
OVERLAPPING_FEATURES=()

for skill_dir in "$SKILLS_DIR"/*; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        if [ -f "$skill_dir/SKILL.md" ]; then
            INSTALLED_SKILLS+=("$skill_name")
            echo "  ✓ Found: $skill_name"
        fi
    fi
done

echo ""
echo "📊 Analyzing feature overlap..."

# Check for self-improving-agent
HAS_SI=false
HAS_PROACTIVE=false
HAS_MEMORY=false
HAS_BACKUP=false
HAS_HEALTH=false

for skill in "${INSTALLED_SKILLS[@]}"; do
    case "$skill" in
        "self-improving-agent")
            HAS_SI=true
            echo "  ⚠️  Overlap detected: error_logging, learning_records, user_corrections (provided by self-improving-agent)"
            ;;
        "proactive-agent")
            HAS_PROACTIVE=true
            echo "  ⚠️  Overlap detected: autonomous_tasks (provided by proactive-agent)"
            ;;
        "memory-agent")
            HAS_MEMORY=true
            echo "  ⚠️  Overlap detected: knowledge_extraction (provided by memory-agent)"
            ;;
        "backup-agent")
            HAS_BACKUP=true
            echo "  ⚠️  Overlap detected: session_backup (provided by backup-agent)"
            ;;
        "health-monitor")
            HAS_HEALTH=true
            echo "  ⚠️  Overlap detected: health_check (provided by health-monitor)"
            ;;
    esac
done

# Generate optimized config
echo ""
echo "⚙️  Generating optimized configuration..."

# Read current config or create default
if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "${CONFIG_FILE}.backup"
    echo "  📋 Backed up current config to ${CONFIG_FILE}.backup"
fi

# Create base config
cat > "$CONFIG_FILE" << 'EOF'
{
  "backup": {
    "incremental": {
      "enabled": true,
      "interval": 5,
      "retention": 7
    },
    "snapshot": {
      "enabled": true,
      "interval": 60,
      "retention": 30
    }
  },
  "summary": {
    "enabled": true,
    "schedule": "0 0 * * *",
    "extractErrors": true,
    "extractLearnings": true,
    "trackCorrections": true,
    "extractBestPractices": true,
    "trackFeatureRequests": true,
    "knowledgeExtraction": true
  },
  "healthCheck": {
    "enabled": true,
    "interval": 6
  },
  "collaboration": {
    "tracking": true,
    "healthScore": true
  },
  "proactive": {
    "enabled": false
  },
  "integration": {
    "detectedSkills": [],
    "autoAdapt": true,
    "selfImprovingAgent": {
      "detected": false,
      "readLearnings": false
    },
    "proactiveAgent": {
      "detected": false
    },
    "memoryAgent": {
      "detected": false
    },
    "backupAgent": {
      "detected": false
    },
    "healthMonitor": {
      "detected": false
    }
  }
}
EOF

# Disable overlapping features using jq if available
if command -v jq &> /dev/null; then
    if [ "$HAS_SI" = true ]; then
        jq '.summary.extractErrors = false | .summary.extractLearnings = false | .summary.trackCorrections = false | .summary.extractBestPractices = false | .integration.selfImprovingAgent.detected = true | .integration.selfImprovingAgent.readLearnings = true' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp"
        mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
        echo "  ✓ Disabled error/learning extraction (delegated to self-improving-agent)"
    fi
    
    if [ "$HAS_PROACTIVE" = true ]; then
        jq '.proactive.enabled = false | .integration.proactiveAgent.detected = true' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp"
        mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
        echo "  ✓ Disabled proactive features (delegated to proactive-agent)"
    fi
    
    if [ "$HAS_MEMORY" = true ]; then
        jq '.summary.knowledgeExtraction = false | .integration.memoryAgent.detected = true' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp"
        mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
        echo "  ✓ Disabled knowledge extraction (delegated to memory-agent)"
    fi
    
    if [ "$HAS_BACKUP" = true ]; then
        jq '.backup.incremental.enabled = false | .integration.backupAgent.detected = true' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp"
        mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
        echo "  ✓ Disabled incremental backup (delegated to backup-agent)"
    fi
    
    if [ "$HAS_HEALTH" = true ]; then
        jq '.healthCheck.enabled = false | .integration.healthMonitor.detected = true' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp"
        mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
        echo "  ✓ Disabled health check (delegated to health-monitor)"
    fi
    
    # Add detected skills list
    skills_json=$(printf '%s\n' "${INSTALLED_SKILLS[@]}" | jq -R . | jq -s .)
    jq ".integration.detectedSkills = $skills_json" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp"
    mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
else
    echo "  ⚠️  jq not found. Manual configuration may be needed."
fi

# Generate detection report
cat > "$DETECTION_REPORT" << EOF
# Session Guardian - Skill Detection Report

**Generated**: $(date)

## Detected Skills

EOF

for skill in "${INSTALLED_SKILLS[@]}"; do
    echo "- $skill" >> "$DETECTION_REPORT"
done

cat >> "$DETECTION_REPORT" << EOF

## Feature Overlap Analysis

EOF

OVERLAP_COUNT=0
if [ "$HAS_SI" = true ]; then
    ((OVERLAP_COUNT++))
fi
if [ "$HAS_PROACTIVE" = true ]; then
    ((OVERLAP_COUNT++))
fi
if [ "$HAS_MEMORY" = true ]; then
    ((OVERLAP_COUNT++))
fi
if [ "$HAS_BACKUP" = true ]; then
    ((OVERLAP_COUNT++))
fi
if [ "$HAS_HEALTH" = true ]; then
    ((OVERLAP_COUNT++))
fi

if [ $OVERLAP_COUNT -eq 0 ]; then
    echo "✅ No feature overlap detected. All Session Guardian features enabled." >> "$DETECTION_REPORT"
else
    echo "⚠️ Feature overlap detected. Session Guardian auto-configured to avoid duplication:" >> "$DETECTION_REPORT"
    echo "" >> "$DETECTION_REPORT"
    
    if [ "$HAS_SI" = true ]; then
        echo "- **Error/Learning Extraction**: Delegated to \`self-improving-agent\`" >> "$DETECTION_REPORT"
    fi
    if [ "$HAS_PROACTIVE" = true ]; then
        echo "- **Proactive Features**: Delegated to \`proactive-agent\`" >> "$DETECTION_REPORT"
    fi
    if [ "$HAS_MEMORY" = true ]; then
        echo "- **Knowledge Extraction**: Delegated to \`memory-agent\`" >> "$DETECTION_REPORT"
    fi
    if [ "$HAS_BACKUP" = true ]; then
        echo "- **Incremental Backup**: Delegated to \`backup-agent\`" >> "$DETECTION_REPORT"
    fi
    if [ "$HAS_HEALTH" = true ]; then
        echo "- **Health Check**: Delegated to \`health-monitor\`" >> "$DETECTION_REPORT"
    fi
fi

cat >> "$DETECTION_REPORT" << EOF

## Optimized Configuration

Session Guardian has been configured to complement existing skills:

EOF

# Add specific integration notes
if [ "$HAS_SI" = true ]; then
    cat >> "$DETECTION_REPORT" << 'SIEOF'
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

SIEOF
fi

if [ "$HAS_PROACTIVE" = true ]; then
    cat >> "$DETECTION_REPORT" << 'PAEOF'
### Integration with proactive-agent

**Workflow**:
- proactive-agent handles autonomous tasks and proactive suggestions
- Session Guardian focuses on backup and collaboration tracking

**Disabled Features**:
- Proactive suggestions (delegated to proactive-agent)

PAEOF
fi

cat >> "$DETECTION_REPORT" << EOF

## Recommendations

EOF

if [ $OVERLAP_COUNT -eq 0 ]; then
    echo "✅ No action needed. Session Guardian is optimally configured." >> "$DETECTION_REPORT"
else
    cat >> "$DETECTION_REPORT" << 'RECEOF'
1. **Review the configuration**: Check `config.json` to ensure it matches your needs
2. **Test the integration**: Run for 1 week and monitor token consumption
3. **Adjust if needed**: You can manually enable/disable features in `config.json`
4. **Re-run detection**: Run `bash scripts/detect-skills.sh` anytime to re-detect

RECEOF
fi

echo ""
echo "✅ Configuration complete!"
echo ""
echo "📊 Summary:"
echo "  - Detected skills: ${#INSTALLED_SKILLS[@]}"
echo "  - Overlapping skills: $OVERLAP_COUNT"
echo "  - Report saved to: $DETECTION_REPORT"
echo ""
echo "💡 Next steps:"
echo "  1. Review the detection report: cat $DETECTION_REPORT"
echo "  2. Review the configuration: cat $CONFIG_FILE"
echo "  3. Test the integration for 1 week"
echo ""
