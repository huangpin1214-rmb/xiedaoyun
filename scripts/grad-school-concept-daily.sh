#!/bin/bash
# 研究生小众概念每日推送
# 每天 22:00 执行，从概念库随机选一个，用三段式故事讲解

OPENCLAW_JSON="/Users/edy/.openclaw/openclaw.json"
LOG="/Users/edy/.openclaw/workspace/.backup.log"

# 概念库（研究生才懂的小众概念）
declare -a CONCEPTS=(
  "幸存者偏差|当样本筛选出失败者后，幸存的结果会系统性地高估成功概率——就像返回的飞机翅膀弹孔多，不代表翅膀最该加固，因为被打中翅膀的飞机根本没能返航。|故事：一个将军看着返航飞机浑身弹孔，决定加固翅膀。统计学家说：不对，那些引擎中弹的飞机根本没能回来。|这对应了幸存者偏差的核心：只看到幸存者会严重歪曲你对真实的认知。"
  "心智模型|人脑为了降低认知成本，用简化的框架来理解世界——就像地图不是领土本身，但能帮你导航。|故事：新来的管理员走进图书馆迷宫，看见读者们总走同一条路，就跟着走。走了100次后，他以为这条路是最近的路——其实那是前辈们当年摸索出来的，虽然迂回，但沿途有插座和灯。|心智模型就是我们脑中的'默认路径'，它让我们快速决策，但也会让我们在环境变化时踩坑。"
  "能力圈|知道自己真正懂什么、不懂什么，只在懂的范围内行动——就像钓鱼佬知道自己能在哪片水域钓鱼。|故事：一个短线交易者听说隔壁老王买科技股赚了三倍，也跟着买。结果科技股大跌，他却不知道什么时候该卖——因为他根本不懂这项技术。|能力圈的意义在于：知道自己几斤几两，不懂的东西涨再多也跟你没关系。"
  "反向推理|不直接问'怎么成功'，而是问'什么行为必然导致失败'，然后避免它。|故事：老师问：如何确保这辈子不破产？有人回答'永远不花超过你赚的'。老师说：对，财富的秘诀不是拼命赚钱，而是永远不犯大错。|反向推理的精髓：想成功，先研究怎么不失败，然后把那些坑全部绕过。"
  "路径依赖|一旦进入某个轨道，就很难跳出来——就像磁带一旦卡住，就会一直循环播放同一段。|故事：录像带时代的VHS和Beta格式大战。Beta画质更好，但VHS先占领了市场，有了更多录像带，消费者就买VHS；消费者越多，厂商越愿意生产VHS。画质更好的Beta就这么消失了。|路径依赖告诉我们：起步优势可能比'更好'更重要，一旦形成惯性，改变几乎不可能。"
)

# 随机选一个概念
NUM=${#CONCEPTS[@]}
IDX=$((RANDOM % NUM))
IFS='|' read -r CONCEPT REST <<< "${CONCEPTS[$IDX]}"

# 提取概念名和故事部分
IFS='|' read -r NAME STORY REVEAL <<< "$REST"

# 推送内容（飞书不支持markdown，用纯文本）
MESSAGE="🌙 研究生小众概念｜睡前一个

📖 故事：

$STORY

$REVEAL

---
明晚同一时间，再送你一个 🍎"

# 发送到飞书（直接消息给频哥）
CHANNEL_JSON=$(python3 -c "import json; d=json.load(open('$OPENCLAW_JSON')); print(d.get('channels',{}).get('feishu',{}).get('channels',[])[0].get('channelId',''))" 2>/dev/null)

# 使用 feishu user direct message 发送
python3 << EOF
import subprocess, json, urllib.request, urllib.parse

# Get feishu token
cfg = json.load(open('$OPENCLAW_JSON'))
app_id = cfg['channels']['feishu']['appId']
app_secret = cfg['channels']['feishu']['appSecret']

# Get tenant token
req = urllib.request.Request(
    'https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal',
    data=json.dumps({'app_id': app_id, 'app_secret': app_secret}).encode(),
    headers={'Content-Type': 'application/json'}
)
with urllib.request.urlopen(req, timeout=10) as resp:
    token_data = json.loads(resp.read())
tenant_token = token_data.get('tenant_access_token', '')

# Send message to user
user_open_id = 'ou_2ad19bb3863e71e2d0eff5cc4aeedd83'
msg = '''$MESSAGE'''

send_req = urllib.request.Request(
    f'https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=open_id',
    data=json.dumps({
        'receive_id': user_open_id,
        'msg_type': 'text',
        'content': json.dumps({'text': msg})
    }).encode(),
    headers={
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {tenant_token}'
    }
)
with urllib.request.urlopen(send_req, timeout=10) as resp:
    result = json.loads(resp.read())
    if result.get('code') == 0:
        print('OK')
    else:
        print('FAIL:', result.get('msg'))
EOF

echo "$(date '+%Y-%m-%d %H:%M:%S') graduate concept push: $NAME" >> "$LOG"
