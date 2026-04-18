#!/bin/bash
# 生物实验复习提醒 - 一次性早中晚三次提醒

python3 << 'PYEOF'
import subprocess, json, os, datetime, time

APP_ID = "cli_a93534f5edb85bd3"
CONFIG_FILE = os.path.expanduser("~/.openclaw/openclaw.json")
with open(CONFIG_FILE) as f:
    feishu_cfg = json.load(f).get("channels", {}).get("feishu", {})
APP_SECRET = feishu_cfg.get("appSecret", "")
USER_OPEN_ID = "ou_2ad19bb3863e71e2d0eff5cc4aeedd83"

def get_token():
    result = subprocess.run(
        ["curl", "-s", "-X", "POST",
         "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal",
         "-H", "Content-Type: application/json",
         "-d", json.dumps({"app_id": APP_ID, "app_secret": APP_SECRET})],
        capture_output=True, text=True
    )
    return json.loads(result.stdout).get("tenant_access_token", "")

def send_msg(token, text):
    subprocess.run(
        ["curl", "-s", "-X", "POST",
         "https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=open_id",
         "-H", f"Authorization: Bearer {token}",
         "-H", "Content-Type: application/json",
         "-d", json.dumps({
             "receive_id": USER_OPEN_ID,
             "msg_type": "text",
             "content": json.dumps({"text": text})
         })],
        capture_output=True
    )

token = get_token()
if not token:
    print("获取 token 失败")
    exit(1)

today = datetime.date.today()
tomorrow = today + datetime.timedelta(days=1)

slots = [
    (datetime.datetime(tomorrow.year, tomorrow.month, tomorrow.day, 8, 0), "🌅 早安！兮兮今天要复习生物实验操作哦，记得督促她过一遍要点～"),
    (datetime.datetime(tomorrow.year, tomorrow.month, tomorrow.day, 14, 0), "☀️ 下午提醒：兮兮生物实验复习得怎么样了？明天就考了，今天再过一遍！"),
    (datetime.datetime(tomorrow.year, tomorrow.month, tomorrow.day, 19, 0), "🌙 晚间提醒：兮兮生物实验明天就要考了，今晚最后确认一遍操作要点！"),
]

now = datetime.datetime.now()
for target_time, msg in slots:
    wait_secs = (target_time - now).total_seconds()
    if wait_secs > 0:
        print(f"等待 {int(wait_secs)} 秒，直到 {target_time.strftime('%H:%M')}")
        time.sleep(wait_secs)
        send_msg(token, msg)
        print(f"已发送: {target_time.strftime('%H:%M')}")

print("生物实验复习提醒全部完成")
PYEOF
