#!/bin/bash
# 智能分析agent的compaction策略
# 用法: bash analyze-agent-compaction.sh <agent-id>

set -e

AGENT_ID="${1:-dev-ui-designer}"
WORKSPACE_ROOT="$HOME/.openclaw"
AGENT_DIR="$WORKSPACE_ROOT/agents/$AGENT_ID"
OUTPUT_DIR="$WORKSPACE_ROOT/workspace/Assets/SessionBackups/compaction-analysis"

mkdir -p "$OUTPUT_DIR"

echo "🔍 分析Agent: $AGENT_ID"

# 1. 收集agent信息
echo "📋 收集agent配置..."

AGENT_INFO=""

# 读取AGENTS.md
if [ -f "$AGENT_DIR/agent/AGENTS.md" ]; then
  AGENT_INFO+="=== AGENTS.md ===\n"
  AGENT_INFO+="$(head -100 "$AGENT_DIR/agent/AGENTS.md")\n\n"
fi

# 读取IDENTITY.md
if [ -f "$AGENT_DIR/agent/IDENTITY.md" ]; then
  AGENT_INFO+="=== IDENTITY.md ===\n"
  AGENT_INFO+="$(cat "$AGENT_DIR/agent/IDENTITY.md")\n\n"
fi

# 读取最近的session统计
SESSION_DIR="$AGENT_DIR/sessions"
if [ -d "$SESSION_DIR" ]; then
  LATEST_SESSION=$(ls -t "$SESSION_DIR"/*.jsonl 2>/dev/null | head -1)
  if [ -n "$LATEST_SESSION" ]; then
    LINE_COUNT=$(wc -l < "$LATEST_SESSION")
    FILE_SIZE=$(du -h "$LATEST_SESSION" | cut -f1)
    AGENT_INFO+="=== Session统计 ===\n"
    AGENT_INFO+="最近session: $(basename "$LATEST_SESSION")\n"
    AGENT_INFO+="消息数: $LINE_COUNT\n"
    AGENT_INFO+="文件大小: $FILE_SIZE\n\n"
  fi
fi

# 从openclaw.json读取agent配置
AGENT_CONFIG=$(jq -r ".agents.list[] | select(.id == \"$AGENT_ID\")" "$WORKSPACE_ROOT/openclaw.json" 2>/dev/null || echo "{}")
if [ "$AGENT_CONFIG" != "{}" ]; then
  AGENT_INFO+="=== OpenClaw配置 ===\n"
  AGENT_INFO+="$(echo "$AGENT_CONFIG" | jq -r '{name, workspace, tools: .tools.allow, subagents: .subagents.allowAgents}')\n\n"
fi

# 2. 生成分析提示词
ANALYSIS_PROMPT="你是OpenClaw的compaction策略专家。请分析以下agent的配置和使用场景，为它生成个性化的compaction策略。

Agent ID: $AGENT_ID

Agent信息:
$(echo -e "$AGENT_INFO")

请分析：
1. 职责范围：这个agent主要做什么？需要多少历史上下文？
2. 工作模式：长期项目还是短期任务？
3. 协作频率：经常和其他agent协作吗？
4. 输出类型：主要产出什么（代码/文档/分析/执行）？

基于分析，给出：
1. 推荐的token阈值（百分比，如60%表示120k/200k时触发压缩）
2. 压缩时机建议（任务完成后/每日/阈值触发）
3. 压缩指令模板（告诉/compact保留什么，压缩什么）

输出JSON格式：
{
  \"analysis\": {
    \"role\": \"职责描述\",
    \"workMode\": \"长期项目|短期任务|混合\",
    \"collaborationFrequency\": \"高|中|低\",
    \"outputType\": \"代码|文档|分析|执行\"
  },
  \"recommendation\": {
    \"tokenThreshold\": 60,
    \"compactionTiming\": \"任务完成后|每日|阈值触发\",
    \"compactionInstruction\": \"保留任务目标和交付物，压缩执行过程\"
  }
}"

# 3. 调用LLM分析
echo "🤖 调用LLM分析..."

ANALYSIS_RESULT=$(openclaw chat --agent main --message "$ANALYSIS_PROMPT" --json 2>/dev/null || echo "{}")

# 4. 保存结果
OUTPUT_FILE="$OUTPUT_DIR/$AGENT_ID-analysis.json"
echo "$ANALYSIS_RESULT" > "$OUTPUT_FILE"

echo "✅ 分析完成，结果保存到: $OUTPUT_FILE"
echo ""
echo "📊 分析结果："
echo "$ANALYSIS_RESULT" | jq '.' 2>/dev/null || echo "$ANALYSIS_RESULT"
