#!/bin/bash
# getnote-sprout-push.sh - 每天发芽内容推送（AI自主生成版）
# cron: 30 21 * * * /Users/edy/.openclaw/workspace/scripts/getnote-sprout-push.sh

WORKSPACE="$HOME/.openclaw/workspace"
LOG_FILE="$WORKSPACE/.backup.log"
DATE_DISPLAY=$(date +"%Y年%m月%d日")

echo "🌱 开始发芽推送... $DATE_DISPLAY"

python3 << 'PYEOF'
# -*- coding: utf-8 -*-
import subprocess, json, os, datetime, random

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

token = get_token()
if not token:
    print("获取 token 失败")
    exit(1)

# 发芽内容库（基于今日对话和教育规律）
spouts = [
    {
        "theme": "错题本是诊所，不是仓库",
        "insight": "录错题不是为了'我有在整理'，是为了下次不犯同一个错。",
        "detail": "今天检查了兮兮的地理答题，发现'伦敦多阴雨天'这个关键词漏掉了。真正的错题本应该像诊所——诊断→治疗→不复发。如果只是抄一遍答案，那是仓库存货，不是治疗方案。建议每次录完错题，问自己一句：'下次遇到类似题，我会怎么想到这个坑？'"
    },
    {
        "theme": "生地会考：现在就要开始抢时间了",
        "insight": "4月27日生物实验操作考，5月生地笔试，时间不等人。",
        "detail": "初二下学期最大的战役就是生地会考。生物实验操作考什么？小鱼尾鳍血流观察、洋葱表皮、花结构解剖——很多孩子不是不会，是不敢动手。建议最近两周每周末在家练一次操作，突破心理关。记住：不能赌抽到简单题，要把所有可能性都练熟。"
    },
    {
        "theme": "英语AB卷倒挂：习惯问题，不是能力问题",
        "insight": "B卷能排118名，A卷排384名——说明卷子不难，但习惯丢了。",
        "detail": "老师说的很清楚：兮兮的A卷失分不是不会，是习惯问题。审题漏读、卷面乱、答完不检查——这些问题不解决，刷再多题也没用。建议每天英语作业额外加5分钟：做完检查一遍有没有漏题、拼写有没有低级错误。习惯比聪明更重要。"
    },
    {
        "theme": "睡前15分钟，记忆黄金期",
        "insight": "研究证明：睡前复习的内容会在睡眠中更好地转入长期记忆。",
        "detail": "如果兮兮每天有背单词、古诗、文综知识点，放到睡前15分钟做，而不是早起背。早起背是大水漫灌，睡前复习是精准灌溉。大脑在睡眠中会自动整理白天学的内容，这时候喂进去的东西记得更牢。试一个月看看效果。"
    },
    {
        "theme": "青春期：关系好了再谈学习",
        "insight": "教育学首先是关系学——和孩子关系好了，她才愿意听你的。",
        "detail": "13-14岁正是青春期，特点是想独立、被尊重、被当大人对待。这时候你还天天'作业写了吗''怎么又粗心了'，她只想逃。换个方式：每周找一次机会聊点她感兴趣的话题（周深？同学八卦？都可以），先让她觉得'我爸/妈还挺能聊'，再找机会聊学习，别着急，慢慢来。"
    },
    {
        "theme": "刷题不复盘=白刷",
        "insight": "做10道题不如彻底搞懂1道题——复盘才是提分的关键。",
        "detail": "英语报做完了，对完答案就扔？错。真正有效的学习是：做题→对答案→分析错因→找到知识盲点→同类题练习。任何一道错题，都是一个提升的机会。刷题不复盘，等于花钱买彩票——浪费。"
    },
    {
        "theme": "物理：受力分析是根基",
        "insight": "力学所有问题都从受力分析开始——漏一个力，全题皆输。",
        "detail": "兮兮的受力分析容易漏力。老师给了一个检查技巧：'如果算出来的力不是选项里最大的，大概率漏了'。做力学题时，先把所有可能的力都列出来（重力、弹力、摩擦力），再一个个排查是否实际作用。做完后用这个检查一下，能救回不少分。"
    },
    {
        "theme": "目标要分解，不然就是空话",
        "insight": "'中考考好'不是目标，'数学争取145分'才是目标。",
        "detail": "校长在家长会上特别强调：内驱力来自清晰的目标。现在跟兮兮聊中考，不能只说'要考好'，而是具体到'英语A卷多拿5分''数学压轴题第二问争取拿分'这样的具体小目标。目标越具体，路径越清晰，动力越足。"
    }
]

spout = random.choice(spouts)
now = datetime.datetime.now().strftime("%m月%d日")
content = f"""🌱 每日发芽 | {now}

📌 {spout['theme']}
{spout['insight']}

{spout['detail']}

---
💡 来自谢道韫 · 每日教育洞察"""

send_message(token, content)
print("🌱 发芽推送已发送")
PYEOF

echo "✅ 发芽推送完成: $(date)" | tee -a "$LOG_FILE"
