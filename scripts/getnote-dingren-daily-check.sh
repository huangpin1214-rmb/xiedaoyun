#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
盯人日报每日检查脚本（优化版）
- 检查 Get笔记 知识库 EJ9zwkln 是否有新笔记
- 推送策略：
  1. 盯人日报（#数字）：直接推送 → 输出结构化摘要（深读要点 + 链接）
  2. 其他相关笔记：包含 AI/教育/孩子 等关键词的优质内容
- 优化：不再只推标题，而是输出结构化摘要（深读要点 + 链接）
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

def clean_title(t):
    """清理盯人日报标题：去掉 emoji、日期后缀，保留期号"""
    t = t.strip()
    t = re.sub(r'[\U0001F300-\U0001F9FF\u2600-\u26FF\u2700-\u27BF]+\s*', '', t)
    t = t.replace('\uFE0F', '')
    t = re.sub(r'\s*\|\s*\d{4}-\d{2}-\d{2}\s*$', '', t)
    t = re.sub(r'\s+', ' ', t)
    t = re.sub(r'^#\s*', '', t)
    m = re.match(r'盯人日报\s*#(\d+)', t)
    if m:
        return f'盯人日报 #{m.group(1)}'
    return t.strip()

def extract_summary(content):
    """从笔记内容中提取摘要（取 💡 和 📝 开头的行）"""
    if not content:
        return ""
    fragments = []
    for line in content.split('\n'):
        line = line.strip()
        if line.startswith('💡'):
            fragments.append(line.replace('💡', '').strip())
        elif line.startswith('📝'):
            fragments.append(line.replace('📝', '').strip())
    return ' | '.join(fragments[:3]) if fragments else ""

def extract_links(content):
    """从内容中提取链接（取前3个，清理末尾非法字符）"""
    if not content:
        return []
    urls = re.findall(r'https?://[\S]+', content)
    seen = set()
    result = []
    for url in urls:
        # 去掉末尾的全角括号/半角括号及其他异常字符
        url_clean = re.sub(r'[\)）\]\>]+$', '', url)
        if url_clean.startswith('http') and 'biji.com' not in url_clean and url_clean not in seen:
            seen.add(url_clean)
            result.append(url_clean)
    return result[:3]

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

    # 分类：盯人日报 vs 其他
    dingren_notes = []
    other_notes = []

    ai_edu_keywords = [
        "AI", "人工智能", "大模型", "ChatGPT", "Claude", "Gemini", "GPT", "LLM",
        "模型", "神经网络", "深度学习", "AGI", "Scaling",
        "教育", "学习", "考试", "中考", "高考", "孩子", "女儿", "成长", "育儿", "亲子",
        "吴军", "脱不花", "池晓", "曾诚", "馒头大师", "汪潮", "大疆"
    ]

    for n in reversed(new_notes):
        title = n.get("title", "")
        content = (n.get("content", "") or "")[:1500]
        combined = title + " " + content

        is_dingren = "盯人日报" in title and bool(re.search(r'盯人日报\s*#\d+', title))

        if is_dingren:
            summary = extract_summary(content)
            urls = extract_links(content)
            dingren_notes.append({
                "title": clean_title(title),
                "summary": summary,
                "urls": urls,
            })
        elif any(kw in combined for kw in ai_edu_keywords):
            urls = extract_links(content)
            other_notes.append({
                "title": clean_title(title),
                "summary": extract_summary(content),
                "urls": urls
            })

    # 更新状态
    with open(STATE_FILE, "w") as f:
        json.dump({"last_note_id": latest_id, "last_check": datetime.now().isoformat()}, f)

    total = len(new_notes)
    today_str = datetime.now().strftime("%m/%d")

    token = get_tenant_token()
    if not token:
        print("飞书 token 失败")
        return

    lines = []
    if dingren_notes:
        for dn in dingren_notes:
            lines.append(f"📬 盯人日报 {today_str}")
            lines.append("")
            lines.append(f"【{dn['title']}】")
            if dn["summary"]:
                lines.append(dn["summary"])
            if dn["urls"]:
                for url in dn["urls"]:
                    lines.append(f"  {url}")
            lines.append("")
        lines.append(f"共{total}条新笔记，本期含{len(dingren_notes)}期盯人日报")
        if other_notes:
            lines.append(f"+ {len(other_notes)}条AI/教育相关笔记")
        lines.append("---")
        lines.append("📎 其他相关笔记：")
        for on in other_notes:
            if on["urls"]:
                lines.append(f"• {on['title']}  {on['urls'][0]}")
            else:
                lines.append(f"• {on['title']}")
    elif other_notes:
        lines.append(f"📬 盯人日报 {today_str}")
        lines.append("")
        for on in other_notes:
            if on["urls"]:
                lines.append(f"• {on['title']}  {on['urls'][0]}")
            else:
                lines.append(f"• {on['title']}")
        lines.append("")
        lines.append(f"共{total}条新笔记，如需查看全部更新告诉我")
    else:
        lines.append(f"📬 盯人日报 {today_str}")
        lines.append("")
        lines.append(f"共{total}条新笔记，本期无直接相关AI/教育内容")
        lines.append("(主要涉及：AI行业动态、技术进展、投资并购等)")
        lines.append("如需查看全部更新，告诉我，我帮你翻")

    msg = "\n".join(lines)
    send_feishu(token, msg)
    print(f"飞书通知已发送 (盯人日报={len(dingren_notes)}, 其他={len(other_notes)}, total={total})")

if __name__ == "__main__":
    main()
