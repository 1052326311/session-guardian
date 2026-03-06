#!/bin/bash
# knowledge-extractor.sh - 军团知识库自动沉淀

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

KNOWLEDGE_DIR="$BACKUP_ROOT/../Knowledge"
CONFIG_FILE="$SCRIPT_DIR/../config.json"
SI_LEARNINGS_DIR="$HOME/.openclaw/workspace/.learnings"

mkdir -p "$KNOWLEDGE_DIR"

# Check if self-improving-agent integration is enabled
read_si_learnings() {
    if [ ! -f "$CONFIG_FILE" ]; then
        return 1
    fi
    
    # Check if SI integration is enabled
    if command -v jq &> /dev/null; then
        local si_enabled=$(jq -r '.integration.selfImprovingAgent.readLearnings // false' "$CONFIG_FILE")
        if [ "$si_enabled" = "true" ] && [ -d "$SI_LEARNINGS_DIR" ]; then
            echo "📖 Reading self-improving-agent learnings..."
            
            local output_file="$KNOWLEDGE_DIR/si-learnings-$(date +%Y%m%d).md"
            
            echo "# Self-Improving-Agent Learnings" > "$output_file"
            echo "**Date**: $(date)" >> "$output_file"
            echo "" >> "$output_file"
            
            # Read ERRORS.md
            if [ -f "$SI_LEARNINGS_DIR/ERRORS.md" ]; then
                echo "## Errors" >> "$output_file"
                tail -50 "$SI_LEARNINGS_DIR/ERRORS.md" >> "$output_file"
                echo "" >> "$output_file"
            fi
            
            # Read LEARNINGS.md
            if [ -f "$SI_LEARNINGS_DIR/LEARNINGS.md" ]; then
                echo "## Learnings" >> "$output_file"
                tail -50 "$SI_LEARNINGS_DIR/LEARNINGS.md" >> "$output_file"
                echo "" >> "$output_file"
            fi
            
            # Read FEATURE_REQUESTS.md
            if [ -f "$SI_LEARNINGS_DIR/FEATURE_REQUESTS.md" ]; then
                echo "## Feature Requests" >> "$output_file"
                tail -20 "$SI_LEARNINGS_DIR/FEATURE_REQUESTS.md" >> "$output_file"
                echo "" >> "$output_file"
            fi
            
            echo "✅ SI learnings saved to: $output_file"
            return 0
        fi
    fi
    
    return 1
}

extract_agent_knowledge() {
    local agent_name="$1"
    local agent_dir=~/.openclaw/agents/$agent_name
    local session_dir="$agent_dir/sessions"
    
    [ -d "$session_dir" ] || { echo "❌ Agent不存在: $agent_name"; return 1; }
    
    local output_dir="$KNOWLEDGE_DIR/$agent_name"
    mkdir -p "$output_dir"
    
    echo "📚 提取知识: $agent_name"
    
    # 提取最佳实践（识别✅标记）
    cat "$session_dir"/*.jsonl 2>/dev/null | grep "✅" | tail -20 > "$output_dir/best-practices.txt"
    
    # 提取常见问题（识别❌标记）
    cat "$session_dir"/*.jsonl 2>/dev/null | grep "❌" | tail -20 > "$output_dir/common-issues.txt"
    
    echo "✅ 知识已提取到: $output_dir"
}

extract_all() {
    echo "📚 提取所有Agent知识..."
    
    # First, read self-improving-agent learnings if enabled
    read_si_learnings
    
    # Then extract from all agents
    for agent_dir in ~/.openclaw/agents/*/; do
        [ -d "$agent_dir" ] || continue
        local agent_name=$(basename "$agent_dir")
        extract_agent_knowledge "$agent_name"
    done
}

case "$1" in
    extract)
        extract_agent_knowledge "$2"
        ;;
    extract-all)
        extract_all
        ;;
    *)
        echo "用法: $0 {extract <agent>|extract-all}"
        exit 1
        ;;
esac
