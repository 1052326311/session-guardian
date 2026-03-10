#!/bin/bash
# session-guardian/scripts/token-monitor.sh
# Token预警监控 v2.2
# 检查所有军团session的token使用率，60%黄色预警，80%红色预警

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Token上限（默认200k，可通过环境变量覆盖）
TOKEN_LIMIT="${TOKEN_LIMIT:-200000}"
WARN_THRESHOLD="${WARN_THRESHOLD:-60}"   # 黄色预警百分比
CRIT_THRESHOLD="${CRIT_THRESHOLD:-80}"   # 红色预警百分比

LOG_FILE="$BACKUP_ROOT/token-monitor.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# 获取所有session的token数据
get_token_data() {
    openclaw sessions --all-agents --json 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
for s in data.get('sessions', []):
    key = s.get('key', '')
    total = s.get('totalTokens') or 0
    if total > 0 and key.endswith(':main') and not ':cron:' in key and not ':subagent:' in key:
        print(f'{key}\t{total}')
" 2>/dev/null
}

# 主函数
main() {
    local alerts=""
    local warn_count=0
    local crit_count=0
    local report=""

    log "=== Token Monitor 检查开始 ==="

    while IFS=$'\t' read -r session_key total_tokens; do
        [ -z "$session_key" ] && continue

        local pct=$((total_tokens * 100 / TOKEN_LIMIT))
        local agent_name=$(echo "$session_key" | sed 's/agent:\(.*\):main/\1/')

        if [ $pct -ge $CRIT_THRESHOLD ]; then
            local msg="🔴 ${agent_name} token ${pct}%（${total_tokens}/${TOKEN_LIMIT}），建议立即reset"
            alerts="${alerts}${msg}\n"
            report="${report}${msg}\n"
            ((crit_count++))
            log "CRITICAL: $session_key = ${pct}% (${total_tokens})"
        elif [ $pct -ge $WARN_THRESHOLD ]; then
            local msg="🟡 ${agent_name} token ${pct}%（${total_tokens}/${TOKEN_LIMIT}），注意观察"
            alerts="${alerts}${msg}\n"
            report="${report}${msg}\n"
            ((warn_count++))
            log "WARNING: $session_key = ${pct}% (${total_tokens})"
        else
            report="${report}✅ ${agent_name} token ${pct}%\n"
            log "OK: $session_key = ${pct}% (${total_tokens})"
        fi
    done < <(get_token_data)

    # 输出报告
    echo ""
    echo "═══ Token Monitor Report ═══"
    echo -e "$report"

    if [ $crit_count -gt 0 ] || [ $warn_count -gt 0 ]; then
        echo "═══ ⚠️ 预警汇总 ═══"
        echo -e "$alerts"
        echo "红色预警: $crit_count | 黄色预警: $warn_count"

        # 写入预警文件供其他脚本读取
        echo -e "$alerts" > "$BACKUP_ROOT/token-alerts.txt"
    else
        echo "✅ 所有session token使用正常"
        rm -f "$BACKUP_ROOT/token-alerts.txt"
    fi

    # v2.2.1: 检查 reserveTokens 配置
    echo ""
    local openclaw_config="$HOME/.openclaw/openclaw.json"
    if [ -f "$openclaw_config" ]; then
        local reserve=$(python3 -c "
import json
with open('$openclaw_config') as f:
    cfg = json.load(f)
print(cfg.get('agents',{}).get('defaults',{}).get('compaction',{}).get('reserveTokens', 50000))
" 2>/dev/null || echo "50000")
        if [ "$reserve" -gt 15000 ] 2>/dev/null; then
            echo "💡 建议: reserveTokens当前为${reserve}，建议调低到15000以减少compaction频率"
        else
            echo "✅ reserveTokens配置合理(${reserve})"
        fi
    fi

    log "=== Token Monitor 检查完成 (crit=$crit_count warn=$warn_count) ==="
}

main "$@"
