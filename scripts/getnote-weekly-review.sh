#!/bin/bash
# getnote-weekly-review.sh - 每周日Get笔记全站复盘
# 使用方法: 加入 crontab: 0 21 * * 0 /Users/edy/.openclaw/workspace/scripts/getnote-weekly-review.sh

WORKSPACE="$HOME/.openclaw/workspace"
LOG_FILE="$WORKSPACE/.backup.log"
DATE=$(date +%Y-%m-%d)
WEEK=$(date +%Y年第%V周)
DATE_FROM=$(date -v-7d +%Y-%m-%d)

echo "📅 开始每周Get笔记复盘... $DATE"

# 读取 Get笔记 配置（从 openclaw.json）
CONFIG_FILE="$HOME/.openclaw/openclaw.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ openclaw.json 未找到，跳过复盘"
    exit 1
fi

GETNOTE_API_KEY=$(python3 -c "
import json
with open('$CONFIG_FILE') as f:
    d = json.load(f)
    entries = d.get('skills', {}).get('entries', {})
    getnote = entries.get('getnote', {})
    print(getnote.get('apiKey', ''))
" 2>/dev/null)

GETNOTE_CLIENT_ID=$(python3 -c "
import json
with open('$CONFIG_FILE') as f:
    d = json.load(f)
    entries = d.get('skills', {}).get('entries', {})
    getnote = entries.get('getnote', {})
    env = getnote.get('env', {})
    print(env.get('GETNOTE_CLIENT_ID', ''))
" 2>/dev/null)

if [ -z "$GETNOTE_API_KEY" ] || [ -z "$GETNOTE_CLIENT_ID" ]; then
    echo "❌ Get笔记 API Key 未配置，跳过复盘"
    exit 1
fi

# ===== 搜索各知识库最近一周的内容 =====
# 由于API不支持按日期过滤，使用语义搜索代替

REVIEW_FILE="$WORKSPACE/memory/getnote_weekly_review_${DATE}.md"

cat > "$REVIEW_FILE" << EOF
# 📅 周复盘 | $WEEK（$DATE_FROM ~ $DATE）

> 自动生成 $(date +%Y-%m-%d\ %H:%M)

EOF

# 搜索函数
search_and_append() {
    local query="$1"
    local section="$2"
    echo "" >> "$REVIEW_FILE"
    echo "## $section" >> "$REVIEW_FILE"
    echo "" >> "$REVIEW_FILE"
    
    result=$(curl -s -X POST "https://openapi.biji.com/open/api/v1/resource/recall" \
        -H "Content-Type: application/json" \
        -H "Authorization: $GETNOTE_API_KEY" \
        -H "X-Client-ID: $GETNOTE_CLIENT_ID" \
        -d "{\"query\":\"$query\",\"top_k\":5}" 2>/dev/null)
    
    echo "$result" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    results = data.get('data', {}).get('results', [])
    if results:
        for r in results[:5]:
            title = r.get('title', '无标题')
            content = r.get('content', '')[:200]
            note_type = r.get('note_type', '')
            created = r.get('created_at', '')
            print(f'### {title}')
            print(f'> 类型: {note_type} | 创建: {created}')
            print(f'> {content}...')
            print('')
    else:
        print('*(无相关笔记)*')
except Exception as e:
    print(f'*(搜索出错: {e})*')
" >> "$REVIEW_FILE"
}

# ===== 按知识库大类搜索 =====

echo "📊 搜索最近一周新增笔记..."

# 芯片业务相关
search_and_append "芯片 半导体 最近" "芯片业务相关"

# AI使用技巧
search_and_append "AI 工具 使用技巧 最近" "AI使用技巧"

# 投资与金融
search_and_append "投资 金融 市场 最近" "投资与金融"

# 孩子教育
search_and_append "孩子 教育 学习 兮兮 最近" "孩子教育"

# 供应链管理
search_and_append "供应链 采购 最近" "供应链管理"

# 一老一小
search_and_append "养老 医疗 健康 最近" "一老一小"

# 网络安全
search_and_append "网络安全 数据 最近" "网络安全"

# ===== 生成总结 =====

cat >> "$REVIEW_FILE" << 'EOF'

---

## 💬 行动建议

本周值得关注的内容：
- 
- 

*由 OpenClaw 自动生成，如需调整请告知*
EOF

echo "📝 复盘文件已生成: $REVIEW_FILE"

# ===== 发送飞书通知 =====

python3 << 'PYEOF'
import subprocess, json, sys, os, datetime

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

# 读取复盘文件
review_date = os.environ.get('DATE', datetime.datetime.now().strftime('%Y-%m-%d'))
review_file = os.path.expanduser(f"~/.openclaw/workspace/memory/getnote_weekly_review_{review_date}.md")

if os.path.exists(review_file):
    with open(review_file, 'r') as f:
        content = f.read()
else:
    content = f"📅 Get笔记周复盘\n\n本周复盘文件已生成，请查看 workspace。"

now_str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
week_str = datetime.datetime.now().strftime("年第%V周")

msg = f"📅 Get笔记 周复盘 | {week_str}\n\n📝 复盘文件已生成：memory/getnote_weekly_review_{review_date}.md\n\n💡 如需调整复盘内容或格式，请随时告知！"

subprocess.run(
    ["curl", "-s", "-X", "POST",
     "https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=open_id",
     "-H", "Authorization: Bearer {app_token}".format(app_token=app_token),
     "-H", "Content-Type: application/json",
     "-d", json.dumps({
         "receive_id": USER_OPEN_ID,
         "msg_type": "text",
         "content": json.dumps({"text": msg})
     })],
    capture_output=True
)
print("飞书通知已发送")
PYEOF

echo "✅ 每周复盘完成: $(date)" | tee -a "$LOG_FILE"
