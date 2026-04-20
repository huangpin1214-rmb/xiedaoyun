#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
兮兮生物实验操作考试提醒脚本
- 每天 8:00 / 12:00 / 18:00 发送飞书提醒
- 倒计时计算
"""

import subprocess, json, os
from datetime import datetime, date

CONFIG_FILE = os.path.expanduser("~/.openclaw/openclaw.json")
USER_OPEN_ID = "ou_2ad19bb3863e71e2d0eff5cc4aeedd83"
EXAM_DATE = date(2026, 4, 24)

def get_token():
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
    return json.loads(result.stdout).get("tenant_access_token", "")

def send_feishu(token, content):
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

def main():
    today = date.today()
    days_left = (EXAM_DATE - today).days
    
    token = get_token()
    if not token:
        return
    
    if days_left < 0:
        msg = f"📅 兮兮生物实验操作考试已结束（4月24日）"
    elif days_left == 0:
        msg = f"📅 今天是兮兮生物实验操作考试！加油！🍎"
    elif days_left == 1:
        msg = f"📅 兮兮生物实验操作考试明天！今天最后冲刺一下实验操作～🍎"
    else:
        msg = f"📅 兮兮生物实验操作考试倒计时 {days_left} 天！别忘了看看兮兮的复习进度～"
    
    send_feishu(token, msg)
    print(f"Sent reminder: {msg}")

if __name__ == "__main__":
    main()
