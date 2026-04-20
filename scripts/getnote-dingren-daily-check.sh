#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
盯人日报每日检查脚本
- 检查 Get笔记 知识库 EJ9zwkln 是否有新笔记
- 过滤 AI/教育 相关内容，有则推送；无则告知"无相关更新"
- cron: 0 8 * * * /Users/edy/.openclaw/workspace/scripts/getnote-dingren-daily-check.sh
"""

import subprocess, json, os, re
from datetime import datetime

WORKSPACE = os.path.expanduser("~/.openclaw/workspace")
STATE_FILE = os.path.expanduser("~/.openclaw/workspace/.dingren_last_check.json")
CONFIG_FILE = os.path.expanduser("~/.openclaw/openclaw.json")
API_KEY = "gk_live_79414cc5d34021a6.f48b009c9ed9470d05fbec8f4ef919f4d657e7a15d91347a"
CLIENT_ID = "cli_a1b2c3d4e5f6789012345678abcdef90"
TOPIC_ID = "EJ9zwkln"
USER_OPEN_ID = "ou_2ad19bb3863e71e2d0eff5cc4aeedd83"

def get_tenant_token():
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

def fetch_latest_notes(page=1):
    result = subprocess.run(
        ["curl", "-s",
         f"https://openapi.biji.com/open/api/v1/resource/knowledge/notes?topic_id={TOPIC_ID}&page={page}",
         "-H", f"Authorization: {API_KEY}",
         "-H", f"X-Client-ID: {CLIENT_ID}"],
        capture_output=True, text=True
    )
    return json.loads(result.stdout)

def main():
    last_id = ""
    if os.path.exists(STATE_FILE):
        with open(STATE_FILE) as f:
            last_id = json.load(f).get("last_note_id", "")

    data = fetch_latest_notes(1)
    notes = data.get("data", {}).get("notes", [])
    
    if not notes:
        print("获取笔记失败")
        return

    latest_id = notes[0]["note_id"]

    # 无新内容
    if latest_id == last_id:
        print("无新内容")
        return

    # 收集所有新笔记
    new_notes = []
    for n in notes:
        if n["note_id"] == last_id:
            break
        new_notes.append(n)

    if not new_notes:
        print("无新内容")
        return

    # 过滤关键词
    ai_edu_keywords = [
        "AI", "人工智能", "大模型", "ChatGPT", "Claude", "Gemini", "GPT", "LLM",
        "模型", "神经网络", "深度学习", "AGI", "Scaling",
        "教育", "学习", "考试", "中考", "高考", "孩子", "女儿", "成长", "育儿", "亲子",
        "吴军", "脱不花", "池晓", "曾诚", "馒头大师", "汪潮", "大疆"
    ]

    def clean_title(t):
        t = re.sub(r"^\[.*?\]\s*", "", t)
        t = re.sub(r"^盯人日报 #\d+ \| \d{4}-\d{2}-\d{2}\s*", "", t)
        return t.strip()

    relevant = []
    for n in reversed(new_notes):
        title = n.get("title", "")
        content = n.get("content", "")[:800]
        combined = title + " " + content
        matched = any(kw in combined for kw in ai_edu_keywords)
        
        url = ""
        if n.get("note_type") == "link":
            urls = re.findall(r"https?://[^\s\)\"\'\\]+", content)
            if urls:
                url = urls[0]

        if matched:
            relevant.append({"title": clean_title(title), "url": url})

    # 更新状态
    with open(STATE_FILE, "w") as f:
        json.dump({"last_note_id": latest_id, "last_check": datetime.now().isoformat()}, f)

    total = len(new_notes)
    today_str = datetime.now().strftime("%m/%d")

    token = get_tenant_token()
    if not token:
        print("飞书 token 失败")
        return

    if relevant:
        lines = [f"📬 盯人日报更新！{today_str} ({len(relevant)}条AI/教育相关)"]
        lines.append("")
        for item in relevant:
            if item["url"]:
                lines.append(f"• {item['title']}")
                lines.append(f"  {item['url']}")
            else:
                lines.append(f"• {item['title']}")
        lines.append("")
        lines.append(f"共{total}条新笔记，向上滚动查看完整更新~")
    else:
        lines = [
            f"📬 盯人日报更新！{today_str}",
            "",
            f"共{total}条新笔记，本期无直接相关AI/教育内容",
            "(主要涉及：AI行业动态、技术进展、投资并购等)",
            "如需查看全部更新，告诉我，我帮你翻"
        ]

    msg = "\n".join(lines)
    send_feishu(token, msg)
    print(f"飞书通知已发送 (relevant={len(relevant)}, total={total})")

if __name__ == "__main__":
    main()
