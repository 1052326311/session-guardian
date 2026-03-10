#!/bin/bash
# 智能分析所有agent的compaction策略
# 输出：每个agent的个性化策略配置

set -e

WORKSPACE_ROOT="$HOME/.openclaw"
OUTPUT_DIR="$WORKSPACE_ROOT/workspace/Assets/SessionBackups/compaction-analysis"
STRATEGY_FILE="$OUTPUT_DIR/compaction-strategies.json"

mkdir -p "$OUTPUT_DIR"

echo "🔍 智能分析所有agent的compaction策略..."
echo ""

# 获取所有agent列表
AGENTS=$(jq -r '.agents.list[].id' "$WORKSPACE_ROOT/openclaw.json")

# 初始化策略文件
echo "{" > "$STRATEGY_FILE"
echo "  \"generated_at\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"," >> "$STRATEGY_FILE"
echo "  \"strategies\": {" >> "$STRATEGY_FILE"

FIRST=true

for AGENT_ID in $AGENTS; do
  echo "📊 分析 $AGENT_ID..."
  
  AGENT_DIR="$WORKSPACE_ROOT/agents/$AGENT_ID"
  AGENT_WORKSPACE="$AGENT_DIR/workspace"
  
  # 收集agent信息
  AGENT_INFO=""
  
  # 读取AGENTS.md
  if [ -f "$AGENT_WORKSPACE/AGENTS.md" ]; then
    AGENT_INFO+="=== AGENTS.md ===\n"
    AGENT_INFO+="$(head -50 "$AGENT_WORKSPACE/AGENTS.md")\n\n"
  fi
  
  # 读取session统计
  SESSION_DIR="$AGENT_DIR/sessions"
  if [ -d "$SESSION_DIR" ]; then
    LATEST_SESSION=$(ls -t "$SESSION_DIR"/*.jsonl 2>/dev/null | head -1)
    if [ -n "$LATEST_SESSION" ]; then
      LINE_COUNT=$(wc -l < "$LATEST_SESSION" 2>/dev/null || echo "0")
      FILE_SIZE=$(du -h "$LATEST_SESSION" 2>/dev/null | cut -f1 || echo "0")
      AGENT_INFO+="=== Session统计 ===\n"
      AGENT_INFO+="消息数: $LINE_COUNT\n"
      AGENT_INFO+="文件大小: $FILE_SIZE\n\n"
    fi
  fi
  
  # 读取agent配置
  AGENT_CONFIG=$(jq -r ".agents.list[] | select(.id == \"$AGENT_ID\")" "$WORKSPACE_ROOT/openclaw.json" 2>/dev/null)
  AGENT_NAME=$(echo "$AGENT_CONFIG" | jq -r '.name // .id')
  TOOLS=$(echo "$AGENT_CONFIG" | jq -r '.tools.allow // [] | join(", ")')
  SUBAGENTS=$(echo "$AGENT_CONFIG" | jq -r '.subagents.allowAgents // [] | join(", ")')
  
  AGENT_INFO+="=== OpenClaw配置 ===\n"
  AGENT_INFO+="名称: $AGENT_NAME\n"
  AGENT_INFO+="工具: $TOOLS\n"
  AGENT_INFO+="协作: $SUBAGENTS\n"
  
  # 生成分析提示（简化版，实际使用时调用LLM）
  # 这里用规则引擎快速生成策略
  
  # 规则引擎：根据agent特征推断策略
  TOKEN_THRESHOLD=60
  TIMING="阈值触发"
  INSTRUCTION="保留关键决策和交付物，压缩执行过程"
  SUMMARY_FOCUS="任务完成情况和关键交付物"
  HEALTH_SESSION_SIZE_MB=50
  HEALTH_TOKEN_WARNING=60
  
  # King：最保守
  if [ "$AGENT_ID" = "main" ]; then
    TOKEN_THRESHOLD=70
    TIMING="阈值触发"
    INSTRUCTION="保留所有军团派发历史、验收结果和关键决策，压缩工具调用细节"
    SUMMARY_FOCUS="军团协作链路、任务派发与验收、关键决策、待办事项"
    HEALTH_SESSION_SIZE_MB=100
    HEALTH_TOKEN_WARNING=70
  
  # 团长：平衡
  elif [[ "$AGENT_ID" == *"-lead" ]]; then
    TOKEN_THRESHOLD=65
    TIMING="阈值触发"
    INSTRUCTION="保留项目上下文、任务分配和成员协作历史，压缩执行细节"
    SUMMARY_FOCUS="项目进度、成员协作、里程碑达成、待解决问题"
    HEALTH_SESSION_SIZE_MB=70
    HEALTH_TOKEN_WARNING=65
  
  # 成员：激进
  else
    TOKEN_THRESHOLD=55
    TIMING="任务完成后"
    INSTRUCTION="保留最近3个任务的交付物和关键规范，压缩过程细节"
    SUMMARY_FOCUS="任务完成情况、交付物质量、技术难点、经验积累"
    HEALTH_SESSION_SIZE_MB=40
    HEALTH_TOKEN_WARNING=55
  fi
  
  # 输出JSON
  if [ "$FIRST" = false ]; then
    echo "," >> "$STRATEGY_FILE"
  fi
  FIRST=false
  
  cat >> "$STRATEGY_FILE" << EOF
    "$AGENT_ID": {
      "name": "$AGENT_NAME",
      "compaction": {
        "tokenThreshold": $TOKEN_THRESHOLD,
        "timing": "$TIMING",
        "instruction": "$INSTRUCTION"
      },
      "summary": {
        "focus": "$SUMMARY_FOCUS"
      },
      "health": {
        "sessionSizeMB": $HEALTH_SESSION_SIZE_MB,
        "tokenWarningPercent": $HEALTH_TOKEN_WARNING
      }
    }
EOF

  echo "  ✅ $AGENT_ID: ${TOKEN_THRESHOLD}% 阈值"
done

echo "" >> "$STRATEGY_FILE"
echo "  }" >> "$STRATEGY_FILE"
echo "}" >> "$STRATEGY_FILE"

echo ""
echo "✅ 分析完成！策略保存到: $STRATEGY_FILE"
echo ""
echo "📋 策略摘要："
jq -r '.strategies | to_entries[] | "  \(.key): 压缩\(.value.compaction.tokenThreshold)% | 健康\(.value.health.tokenWarningPercent)% | 总结侧重: \(.value.summary.focus | .[0:30])..."' "$STRATEGY_FILE"
