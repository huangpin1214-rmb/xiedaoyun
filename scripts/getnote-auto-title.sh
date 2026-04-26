#!/bin/bash
# 每天9:30自动检查Get笔记，用AI给无标题笔记生成标题
# 依赖：python3, MiniMax API

LOG_DIR="/Users/edy/.openclaw/workspace/logs"
LOG_FILE="$LOG_DIR/getnote-auto-title.log"
mkdir -p "$LOG_DIR"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG_FILE"
}

log "=== 开始执行 ==="

python3 << 'PYEOF'
import urllib.request, json, re, time
from datetime import datetime

GETNOTE_API_KEY = 'gk_live_79414cc5d34021a6.f48b009c9ed9470d05fbec8f4ef919f4d657e7a15d91347a'
GETNOTE_CLIENT_ID = 'cli_a1b2c3d4e5f6789012345678abcdef90'
MINIMAX_API_KEY = 'sk-cp-shEuWarV8jGnD585UxAlI8QVmy0av3NJnvlV8skoPRxMA7VXo3G-x0rHirOuTRXKa2He_-lhgtIUeexFgw0n4lQRam2oxXNZfUkAbSFidq-cQ6J8HkO4EQs'
today = datetime.now().strftime('%Y-%m-%d')

def safe_json(text):
    text = re.sub(r'"(id|next_cursor|parent_id|note_id|user_id|kb_id)\s*:\s*(\d+)', r'"\1":"\2"', text)
    text = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f]', '', text)
    return text

def gen_title_m2(content):
    """用 MiniMax M2.7 生成标题，从 reasoning_content 解析"""
    if not content or len(content.strip()) < 5:
        return None
    
    body = json.dumps({
        'model': 'MiniMax-M2.7',
        'messages': [
            {'role': 'system', 'content': '你是一个标题生成器，直接输出标题，不超过20字，不要解释。'},
            {'role': 'user', 'content': f'给这个笔记起一个标题：{content[:500]}'}
        ],
        'temperature': 0.3,
        'max_tokens': 150
    }).encode()
    
    req = urllib.request.Request(
        'https://api.minimax.chat/v1/text/chatcompletion_v2',
        data=body,
        headers={'Authorization': f'Bearer {MINIMAX_API_KEY}', 'Content-Type': 'application/json'}
    )
    with urllib.request.urlopen(req, timeout=15) as resp:
        r = json.loads(resp.read())
        rc = r['choices'][0]['message']['reasoning_content']
        
        # 解析：提取所有引号内容，第一个是用户输入，其余是候选标题
        quotes = re.findall(r'"([^"]+)"', rc)
        if len(quotes) >= 2:
            # 去掉第一条（用户输入），取最短的候选标题
            candidates = [q for q in quotes[1:] if len(q) >= 4]
            if candidates:
                return min(candidates, key=len)
        
        # 备用：取最后一个非空行
        lines = [l.strip() for l in rc.split('\n') if l.strip() and not l.strip().startswith('-')]
        return lines[-1][:20] if lines else None

# 获取今天新增的无标题笔记
cursor = '0'
today_notes = []

for page in range(50):
    url = f'https://openapi.biji.com/open/api/v1/resource/note/list?since_id={cursor}'
    req = urllib.request.Request(url, headers={'Authorization': GETNOTE_API_KEY, 'X-Client-ID': GETNOTE_CLIENT_ID})
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            raw = resp.read().decode('utf-8', errors='replace')
            data = json.loads(safe_json(raw))
    except Exception as e:
        print(f"API请求失败: {e}")
        break

    notes = data.get('data', {}).get('notes', [])
    if not notes:
        break

    for n in notes:
        created = n.get('created_at', '')
        if isinstance(created, int):
            from datetime import timezone
            created = datetime.fromtimestamp(created, tz=timezone.utc).strftime('%Y-%m-%d')
        elif isinstance(created, str) and len(created) > 10:
            created = created[:10]
        
        if created == today and not n.get('title', '').strip():
            today_notes.append(n)

    if not data.get('data', {}).get('has_more'):
        break
    cursor = str(data.get('data', {}).get('next_cursor', '0'))
    time.sleep(0.3)

print(f"今天新增无标题笔记: {len(today_notes)} 条", flush=True)

updates_ok = 0
updates_fail = 0

for n in today_notes:
    note_id = n.get('id', '')
    content = n.get('content', '') or ''
    
    title = gen_title_m2(content)
    if not title:
        title = f"无标题笔记 {note_id[:8]}"
    
    # 更新标题
    update_url = 'https://openapi.biji.com/open/api/v1/resource/note/update'
    payload = json.dumps({'note_id': note_id, 'title': title}).encode()
    req = urllib.request.Request(update_url, data=payload, headers={
        'Content-Type': 'application/json',
        'Authorization': GETNOTE_API_KEY,
        'X-Client-ID': GETNOTE_CLIENT_ID
    }, method='POST')
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            result = json.loads(resp.read().decode('utf-8'))
            if result.get('success'):
                print(f"✅ {note_id} → {title}", flush=True)
                updates_ok += 1
            else:
                print(f"❌ {note_id} → 更新失败", flush=True)
                updates_fail += 1
    except Exception as e:
        print(f"❌ {note_id} → 异常: {e}", flush=True)
        updates_fail += 1
    
    time.sleep(1)

print(f"完成: 成功{updates_ok}条, 失败{updates_fail}条", flush=True)
PYEOF

log "=== 执行完成 ==="
