#!/bin/bash
# 智能健康检查 - 根据agent角色使用个性化阈值

set -e

WORKSPACE_ROOT="$HOME/.openclaw"
STRATEGY_FILE="$WORKSPACE_ROOT/workspace/Assets/SessionBackups/compaction-analysis/compaction-strategies.json"
OUTPUT_FILE="$WORKSPACE_ROOT/workspace/Assets/SessionBackups/health-reports/$(date +%Y-%m-%d-%H%M).md"

mkdir -p "$(dirname "$OUTPUT_FILE")"

echo "🏥 智能健康检查..."
echo ""

# 初始化报告
cat > "$OUTPUT_FILE" << EOF
# Session健康检查报告

生成时间: $(date '+%Y-%m-%d %H:%M:%S')

## 检查结果

EOF

# 获取所有agent
AGENTS=$(jq -r '.agents.list[].id' "$WORKSPACE_ROOT/openclaw.json")

ISSUES=0

for AGENT_ID in $AGENTS; do
  AGENT_DIR="$WORKSPACE_ROOT/agents/$AGENT_ID"
  SESSION_DIR="$AGENT_DIR/sessions"
  
  # 获取该agent的健康阈值
  if [ -f "$STRATEGY_FILE" ]; then
    SIZE_THRESHOLD=$(jq -r ".strategies[\"$AGENT_ID\"].health.sessionSizeMB // 50" "$STRATEGY_FILE")
    TOKEN_THRESHOLD=$(jq -r ".strategies[\"$AGENT_ID\"].health.tokenWarningPercent // 60" "$STRATEGY_FILE")
  else
    SIZE_THRESHOLD=50
    TOKEN_THRESHOLD=60
  fi
  
  # 检查session文件大小
  if [ -d "$SESSION_DIR" ]; then
    LATEST_SESSION=$(ls -t "$SESSION_DIR"/*.jsonl 2>/dev/null | head -1)
    if [ -n "$LATEST_SESSION" ]; then
      SIZE_MB=$(du -m "$LATEST_SESSION" 2>/dev/null | cut -f1)
      
      if [ "$SIZE_MB" -gt "$SIZE_THRESHOLD" ]; then
        echo "⚠️  $AGENT_ID: Session文件过大 (${SIZE_MB}MB > ${SIZE_THRESHOLD}MB)"
        echo "### ⚠️ $AGENT_ID" >> "$OUTPUT_FILE"
        echo "- Session文件: ${SIZE_MB}MB (阈值: ${SIZE_THRESHOLD}MB)" >> "$OUTPUT_FILE"
        echo "- 建议: 执行compaction或reset" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        ISSUES=$((ISSUES + 1))
      else
        echo "✅ $AGENT_ID: 健康 (${SIZE_MB}MB)"
      fi
    fi
  fi
done

if [ "$ISSUES" -eq 0 ]; then
  echo "" >> "$OUTPUT_FILE"
  echo "✅ 所有agent健康状态良好" >> "$OUTPUT_FILE"
fi

echo ""
echo "✅ 健康检查完成，报告: $OUTPUT_FILE"
echo "   发现 $ISSUES 个问题"
