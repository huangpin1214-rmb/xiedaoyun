#!/bin/bash
# 每天9:30自动检查Get笔记，给无标题笔记添加标题
# 依赖：python3, jq

PYTHON3_BIN=$(which python3)
GETNOTE_API_KEY="gk_live_79414cc5d34021a6.f48b009c9ed9470d05fbec8f4ef919f4d657e7a15d91347a"
GETNOTE_CLIENT_ID="cli_a1b2c3d4e5f6789012345678abcdef90"
LOG_FILE="/Users/edy/.openclaw/workspace/logs/getnote-auto-title.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG_FILE"
}

mkdir -p "$(dirname "$LOG_FILE")"

log "=== 开始执行 ==="

RESULT=$(python3 << 'PYEOF'
import urllib.request, json, re, time

api_key = 'gk_live_79414cc5d34021a6.f48b009c9ed9470d05fbec8f4ef919f4d657e7a15d91347a'
client_id = 'cli_a1b2c3d4e5f6789012345678abcdef90'

# 获取今天日期 (YYYY-MM-DD)
from datetime import datetime
today = datetime.now().strftime('%Y-%m-%d')

cursor = '0'
today_notes = []

for page in range(20):
    url = f'https://openapi.biji.com/open/api/v1/resource/note/list?since_id={cursor}'
    req = urllib.request.Request(url, headers={'Authorization': api_key, 'X-Client-ID': client_id})
    with urllib.request.urlopen(req, timeout=10) as resp:
        text = resp.read().decode('utf-8', errors='replace')
        def fix_json(t):
            t = re.sub(r'"id"\s*:\s*(\d+)', r'"id":"\1"', t)
            t = re.sub(r'"next_cursor"\s*:\s*(\d+)', r'"next_cursor":"\1"', t)
            t = re.sub(r'"parent_id"\s*:\s*(\d+)', r'"parent_id":"\1"', t)
            t = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f]', '', t)
            return t
        safe = fix_json(text)
        try:
            data = json.loads(safe)
        except:
            break

    notes = data.get('data', {}).get('notes', [])
    if not notes:
        break

    for n in notes:
        created = n.get('created_at', '')
        if created.startswith(today):
            if not n.get('title', '').strip():
                today_notes.append(n)
        elif today_notes:
            break

    if today_notes:
        break

    has_more = data.get('data', {}).get('has_more', False)
    if not has_more:
        break
    cursor = str(data.get('data', {}).get('next_cursor', '0'))
    time.sleep(0.3)

# 生成标题的逻辑
def gen_title(content, note_type):
    if not content:
        return None
    content = content.strip()
    # 取第一行或开头50字
    first_line = content.split('\n')[0][:60].strip()
    # 去除emoji开头
    first_line = re.sub(r'^[\U0001F300-\U0001F9FF]\s*', '', first_line)
    first_line = re.sub(r'^[\📚🔍⚠️🧠💡📊✅❌]+\s*', '', first_line)
    if len(first_line) < 8:
        first_line = content[:50].strip()
    return first_line if first_line else None

updates_needed = []
for n in today_notes:
    content = n.get('content', '')
    title = gen_title(content, n.get('note_type', ''))
    if title:
        updates_needed.append((n['id'], title))

print(json.dumps({"count": len(updates_needed), "updates": updates_needed}, ensure_ascii=False))
PYEOF
)

UPDATED=$(echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('count',0))")
log "发现 $UPDATED 条无标题笔记"

echo "$RESULT" | python3 -c "
import sys, json, urllib.request
d = json.load(sys.stdin)
api_key = 'gk_live_79414cc5d34021a6.f48b009c9ed9470d05fbec8f4ef919f4d657e7a15d91347a'
client_id = 'cli_a1b2c3d4e5f6789012345678abcdef90'
for note_id, title in d.get('updates', []):
    url = 'https://openapi.biji.com/open/api/v1/resource/note/update'
    payload = json.dumps({'note_id': int(note_id), 'title': title}).encode()
    req = urllib.request.Request(url, data=payload, headers={
        'Content-Type': 'application/json',
        'Authorization': api_key,
        'X-Client-ID': client_id
    }, method='POST')
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            result = json.loads(resp.read().decode('utf-8'))
            ok = '✅' if result.get('success') else '❌'
            print(f'{ok} {note_id} → {title}')
    except Exception as e:
        print(f'❌ {note_id} → {e}')
    time.sleep(2)
"

log "=== 执行完成 ==="
