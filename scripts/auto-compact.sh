#!/bin/bash
# 根据策略自动执行compaction
# 每小时运行一次，检查所有agent的token使用率

set -e

WORKSPACE_ROOT="$HOME/.openclaw"
STRATEGY_FILE="$WORKSPACE_ROOT/workspace/Assets/SessionBackups/compaction-analysis/compaction-strategies.json"

# 如果策略文件不存在，先生成
if [ ! -f "$STRATEGY_FILE" ]; then
  echo "⚠️  策略文件不存在，先运行分析..."
  bash "$(dirname "$0")/analyze-all-agents.sh"
fi

echo "🔍 检查所有agent的token使用率..."

# 获取所有session状态
SESSIONS=$(openclaw sessions list --json 2>/dev/null || echo "[]")

# 遍历每个session
echo "$SESSIONS" | jq -c '.[]' | while read -r SESSION; do
  AGENT_ID=$(echo "$SESSION" | jq -r '.agentId')
  SESSION_KEY=$(echo "$SESSION" | jq -r '.sessionKey')
  TOTAL_TOKENS=$(echo "$SESSION" | jq -r '.totalTokens // 0')
  CONTEXT_WINDOW=200000
  
  # 跳过subagent
  if [[ "$SESSION_KEY" == *":subagent:"* ]]; then
    continue
  fi
  
  # 计算使用率
  if [ "$TOTAL_TOKENS" -gt 0 ]; then
    USAGE_PERCENT=$((TOTAL_TOKENS * 100 / CONTEXT_WINDOW))
    
    # 获取该agent的阈值
    THRESHOLD=$(jq -r ".strategies[\"$AGENT_ID\"].compaction.tokenThreshold // 60" "$STRATEGY_FILE")
    INSTRUCTION=$(jq -r ".strategies[\"$AGENT_ID\"].compaction.instruction // \"保留关键信息，压缩执行细节\"" "$STRATEGY_FILE")
    
    echo "  $AGENT_ID: ${USAGE_PERCENT}% (阈值: ${THRESHOLD}%)"
    
    # 超过阈值，执行压缩
    if [ "$USAGE_PERCENT" -ge "$THRESHOLD" ]; then
      echo "    🧹 触发压缩..."
      
      # 发送compact命令到该agent
      openclaw chat --agent "$AGENT_ID" --message "/compact $INSTRUCTION" >/dev/null 2>&1 || true
      
      echo "    ✅ 压缩命令已发送"
    fi
  fi
done

echo "✅ 检查完成"
