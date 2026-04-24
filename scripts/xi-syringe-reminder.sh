#!/bin/bash
# 一次性提醒：针筒相关问题（仅4月25日生效）

DOM=$(date '+%d')
if [[ "$DOM" != "25" ]]; then
    echo "已过4月25日，不再发送"
    exit 0
fi

python3 << 'PYEOF'
import urllib.request, json, subprocess

msg = """💉 提醒：今天和兮兮一起搞懂针筒相关的问题哦～"""

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
