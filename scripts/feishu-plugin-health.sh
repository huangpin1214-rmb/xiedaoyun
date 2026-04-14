#!/bin/bash
# 飞书插件健康检查脚本
# 检查 feishu.enabled 是否被 Git 覆盖重置为 false
# Crontab: 每5分钟检查一次
# */5 * * * * /Users/edy/.openclaw/workspace/scripts/feishu-plugin-health.sh

set -e

WORKSPACE="/Users/edy/.openclaw/workspace"
LOG="$WORKSPACE/.backup.log"

check_and_fix() {
    IS_ENABLED=$(python3 -c "
import json
with open('$WORKSPACE/../openclaw.json', 'r') as f:
    d = json.load(f)
feishu = d.get('plugins', {}).get('entries', {}).get('feishu', {})
enabled = feishu.get('enabled', None)
print('enabled' if enabled == True else 'disabled')
" 2>/dev/null)

    if [ "$IS_ENABLED" = "disabled" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [FEISHU-HEALTH] 飞书插件被重置为false，正在修复..." >> "$LOG"
        python3 -c "
import json
with open('$WORKSPACE/../openclaw.json', 'r') as f:
    d = json.load(f)
d['plugins']['entries']['feishu']['enabled'] = True
with open('$WORKSPACE/../openclaw.json', 'w') as f:
    json.dump(d, f, indent=2, ensure_ascii=False)
print('fixed')
" >> "$LOG" 2>&1
        openclaw gateway restart >> "$LOG" 2>&1
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [FEISHU-HEALTH] 修复完成，Gateway已重启" >> "$LOG"
    fi
}

check_and_fix
