#!/bin/bash
# 智能总结脚本 - 根据agent角色使用个性化总结策略

set -e

WORKSPACE_ROOT="$HOME/.openclaw"
STRATEGY_FILE="$WORKSPACE_ROOT/workspace/Assets/SessionBackups/compaction-analysis/compaction-strategies.json"
AGENT_ID="${1:-main}"

# 检查策略文件
if [ ! -f "$STRATEGY_FILE" ]; then
  echo "⚠️  策略文件不存在，使用默认总结"
  SUMMARY_FOCUS="今日工作总结"
else
  SUMMARY_FOCUS=$(jq -r ".strategies[\"$AGENT_ID\"].summary.focus // \"今日工作总结\"" "$STRATEGY_FILE")
fi

echo "📝 生成 $AGENT_ID 的智能总结..."
echo "   侧重点: $SUMMARY_FOCUS"

# 生成总结提示词
PROMPT="请总结今天的工作，重点关注：$SUMMARY_FOCUS

要求：
1. 使用三要素格式：完成了什么 + 关键结论 + 下一步
2. 不要重复输入数据
3. 突出重点，简洁明了

请生成总结并保存到 memory/$(date +%Y-%m-%d).md"

# 发送总结请求
openclaw chat --agent "$AGENT_ID" --message "$PROMPT" >/dev/null 2>&1 || true

echo "✅ 总结请求已发送"
