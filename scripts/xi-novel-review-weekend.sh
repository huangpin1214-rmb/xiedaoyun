#!/bin/bash
# 周末名著阅读复习提醒
# 周六/周日 9:00 执行（仅本周末：4月25-26日）

DAY=$(date '+%u')  # 周几：1=周一 ... 7=周日
DOM=$(date '+%d')  # 几号

# 仅周六(6)或周日(7)，且是25或26号
if [[ "$DAY" != "6" && "$DAY" != "7" ]]; then
    echo "非周末，不发送提醒 (day=$DAY)"
    exit 0
fi

if [[ "$DOM" != "25" && "$DOM" != "26" ]]; then
    echo "非本周末，不发送提醒 (dom=$DOM)"
    exit 0
fi

python3 << 'PYEOF'
import urllib.request, json, subprocess

msg = """📚 周末名著阅读复习提醒

今天可以抽时间和兮兮一起复习一下名著阅读的相关内容哦～

温馨提醒：复习时注重人物形象、主题思想、经典情节这些核心考点，加油💪"""

# 获取 tenant token
result = subprocess.run(
    ['security', 'find-generic-password', '-s', 'openclaw-feishu-uat',
     '-a', 'cli_a93534f5edb85bd3:ou_2ad19bb3863e71e2d0eff5cc4aeedd83', '-w'],
    capture_output=True, text=True
)
data = json.loads(result.stdout)
token = data.get('accessToken','')

url = 'https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=open_id'
payload = json.dumps({
    'receive_id': 'ou_2ad19bb3863e71e2d0eff5cc4aeedd83',
    'msg_type': 'text',
    'content': json.dumps({'text': msg})
}).encode()

req = urllib.request.Request(url, data=payload, headers={
    'Authorization': f'Bearer {token}',
    'Content-Type': 'application/json'
}, method='POST')

try:
    with urllib.request.urlopen(req, timeout=10) as resp:
        print('发送成功' if resp.status == 200 else f'失败:{resp.status}')
except Exception as e:
    print(f'发送失败: {e}')
PYEOF
