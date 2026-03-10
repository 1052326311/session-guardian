#!/bin/bash
# session-guardian/scripts/context-recovery.sh
# 智能Reset恢复 v2.2
# reset前：自动摘要当前任务进度写入 CONTEXT_RECOVERY.md
# reset后：军团自动读取恢复上下文

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

AGENTS_DIR="${AGENTS_DIR:-$HOME/.openclaw/agents}"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# 用法
usage() {
    echo "用法: $0 <save|restore> <agent-id>"
    echo ""
    echo "  save    - reset前保存上下文摘要"
    echo "  restore - reset后恢复上下文"
    echo ""
    echo "示例:"
    echo "  $0 save dev-lead        # 保存开发团长的上下文"
    echo "  $0 restore dev-lead     # 恢复开发团长的上下文"
    echo "  $0 save-all             # 保存所有军团的上下文"
    exit 1
}

# 从session文件提取最近的对话摘要
extract_context() {
    local agent_id="$1"
    local session_dir="$AGENTS_DIR/$agent_id/sessions"
    local workspace="$AGENTS_DIR/$agent_id/workspace"

    # 找到最新的session文件
    local latest_session=$(ls -t "$session_dir"/*.jsonl 2>/dev/null | head -1)
    if [ -z "$latest_session" ]; then
        echo "# 无活跃session"
        return
    fi

    # 提取最近的assistant消息（最后10条）
    python3 -c "
import json, sys

messages = []
with open('$latest_session') as f:
    for line in f:
        try:
            obj = json.loads(line.strip())
            if obj.get('type') == 'message':
                msg_obj = obj.get('message', {})
                if msg_obj.get('role') == 'assistant':
                    content = msg_obj.get('content', [])
                    for part in content:
                        if isinstance(part, dict) and part.get('type') == 'text':
                            text = part['text']
                            if len(text) > 500:
                                text = text[:500] + '...'
                            messages.append(text)
                            break
        except:
            pass

for m in messages[-10:]:
    print(f'- {m}')
" 2>/dev/null || echo "# 无法解析session文件"
}

# 保存上下文
save_context() {
    local agent_id="$1"
    local workspace="$AGENTS_DIR/$agent_id/workspace"

    if [ ! -d "$workspace" ]; then
        log "ERROR: workspace不存在: $workspace"
        return 1
    fi

    local recovery_file="$workspace/CONTEXT_RECOVERY.md"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    log "保存 $agent_id 的上下文到 $recovery_file"

    cat > "$recovery_file" << EOF
# Context Recovery — $agent_id
> 自动生成于 $timestamp（reset前保存）

## 最近任务进度

$(extract_context "$agent_id")

## 工作空间文件
\`\`\`
$(ls -la "$workspace"/*.md 2>/dev/null | awk '{print $NF}' | xargs -I{} basename {} 2>/dev/null || echo "无")
\`\`\`

## Token使用
$(openclaw sessions --agent "$agent_id" --json 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
for s in data.get('sessions', []):
    key = s.get('key', '')
    total = s.get('totalTokens') or 0
    if ':main' in key:
        print(f'Session: {key}')
        print(f'Total Tokens: {total}')
" 2>/dev/null || echo "无法获取")

## 恢复指引
读取此文件后，你应该：
1. 了解reset前的任务进度
2. 继续未完成的工作
3. 不需要King重新传递完整背景
EOF

    log "✅ 上下文已保存: $recovery_file"
}

# 保存所有军团
save_all() {
    log "=== 保存所有军团上下文 ==="
    for agent_dir in "$AGENTS_DIR"/*/workspace; do
        [ -d "$agent_dir" ] || continue
        local agent_id=$(basename "$(dirname "$agent_dir")")
        # 跳过main
        [ "$agent_id" = "main" ] && continue
        save_context "$agent_id"
    done
    log "=== 全部保存完成 ==="
}

# 主函数
case "${1:-}" in
    save)
        [ -z "${2:-}" ] && usage
        save_context "$2"
        ;;
    save-all)
        save_all
        ;;
    restore)
        [ -z "${2:-}" ] && usage
        local_file="$AGENTS_DIR/$2/workspace/CONTEXT_RECOVERY.md"
        if [ -f "$local_file" ]; then
            echo "📋 恢复文件内容:"
            cat "$local_file"
        else
            echo "⚠️ 无恢复文件: $local_file"
        fi
        ;;
    *)
        usage
        ;;
esac
