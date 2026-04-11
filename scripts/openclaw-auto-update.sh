#!/bin/bash
# openclaw-auto-update.sh - Skills自动更新脚本（不更新OpenClaw版本）
# 每天检查并更新所有Skills
# cron: 0 6 * * * /Users/edy/.openclaw/workspace/scripts/openclaw-auto-update.sh

# 确保 PATH 包含 /usr/local/bin（Node.js 全局命令在这里）
export PATH="/usr/local/bin:$PATH"

WORKSPACE="$HOME/.openclaw/workspace"
LOG_FILE="$WORKSPACE/.backup.log"
DATE=$(date +%Y-%m-%d)

echo "🔄 开始Skills自动更新检查... $DATE"

# ===== 只更新Skills，不更新OpenClaw主程序 =====
echo "📦 检查Skills更新..."
SKILLS_OUTPUT=$(openclaw skills update --all 2>&1)
SKILLS_EXIT=$?

echo "$SKILLS_OUTPUT" > /tmp/skills_update_output.txt
echo "$SKILLS_EXIT" > /tmp/skills_update_exit.txt

# 发送通知
python3 << 'PYEOF'
# -*- coding: utf-8 -*-
import subprocess, json, os, datetime

USER_OPEN_ID = "ou_2ad19bb3863e71e2d0eff5cc4aeedd83"

def get_token():
    CONFIG_FILE = os.path.expanduser("~/.openclaw/openclaw.json")
    with open(CONFIG_FILE) as f:
        feishu_cfg = json.load(f).get("channels", {}).get("feishu", {})
    APP_SECRET = feishu_cfg.get("appSecret", "")
    APP_ID = "cli_a93534f5edb85bd3"
    
    result = subprocess.run(
        ["curl", "-s", "-X", "POST",
         "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal",
         "-H", "Content-Type: application/json",
         "-d", json.dumps({"app_id": APP_ID, "app_secret": APP_SECRET})],
        capture_output=True, text=True
    )
    data = json.loads(result.stdout)
    return data.get("tenant_access_token", "")

def send_message(token, content):
    subprocess.run(
        ["curl", "-s", "-X", "POST",
         "https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=open_id",
         "-H", f"Authorization: Bearer {token}",
         "-H", "Content-Type: application/json; charset=utf-8",
         "-d", json.dumps({
             "receive_id": USER_OPEN_ID,
             "msg_type": "text",
             "content": json.dumps({"text": content}, ensure_ascii=False)
         }, ensure_ascii=False)],
        capture_output=True
    )

try:
    with open('/tmp/skills_update_output.txt', 'r') as f:
        skills_output = f.read()
    with open('/tmp/skills_update_exit.txt', 'r') as f:
        skills_exit = int(f.read().strip())
except:
    skills_output = ""
    skills_exit = 0

token = get_token()
if not token:
    exit(1)

now = datetime.datetime.now().strftime("%m月%d日 %H:%M")

# 解析更新结果
has_update = "updated" in skills_output.lower() or "→" in skills_output
success = skills_exit == 0

if success and has_update:
    lines = skills_output.split('\n')
    updated = [l.strip() for l in lines if '→' in l or '→' in l]
    summary = '\n'.join(updated[:5]) if updated else "有更新"
    
    content = f"""🔄 Skills自动更新报告 | {now}

**有Skills更新！**

{summary if summary else "详见上方日志"}

---
💡 OpenClaw版本已锁定不受影响"""
elif success:
    content = f"""🔄 Skills自动更新报告 | {now}

**全部已是最新版本** ✅

无新版本需要更新。

---
💡 OpenClaw版本已锁定不受影响"""
else:
    content = f"""🔄 Skills自动更新报告 | {now}

**更新遇到问题** ⚠️

{skills_output[:200] if skills_output else '未知错误'}

---
💡 需人工检查"""
    
send_message(token, content)
print("报告已发送")
PYEOF

rm -f /tmp/skills_update_output.txt /tmp/skills_update_exit.txt
echo "✅ 检查完成: $(date)" | tee -a "$LOG_FILE"
