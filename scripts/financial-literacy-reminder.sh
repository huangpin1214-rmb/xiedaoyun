#!/bin/bash
# 每周日财商导师提醒

python3 << 'PYEOF'
import subprocess, json, os, datetime

APP_ID = "cli_a93534f5edb85bd3"
CONFIG_FILE = os.path.expanduser("~/.openclaw/openclaw.json")
with open(CONFIG_FILE) as f:
    feishu_cfg = json.load(f).get("channels", {}).get("feishu", {})
APP_SECRET = feishu_cfg.get("appSecret", "")
USER_OPEN_ID = "ou_2ad19bb3863e71e2d0eff5cc4aeedd83"

result = subprocess.run(
    ["curl", "-s", "-X", "POST",
     "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal",
     "-H", "Content-Type: application/json",
     "-d", json.dumps({"app_id": APP_ID, "app_secret": APP_SECRET})],
    capture_output=True, text=True
)
token_data = json.loads(result.stdout)
app_token = token_data.get("tenant_access_token", "")

if not app_token:
    print("获取 token 失败，跳过通知")
    sys.exit(0)

msg = "💰 财商导师提醒\n\n这周想跟兮兮聊一个财商话题吗？\n说「兮兮这周学什么财商主题」我来给你本周的对话手册～"

subprocess.run(
    ["curl", "-s", "-X", "POST",
     "https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=open_id",
     "-H", f"Authorization: Bearer {app_token}",
     "-H", "Content-Type: application/json",
     "-d", json.dumps({
         "receive_id": USER_OPEN_ID,
         "msg_type": "text",
         "content": json.dumps({"text": msg})
     })],
    capture_output=True
)
print("财商导师提醒已发送")
PYEOF
