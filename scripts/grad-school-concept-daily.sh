#!/bin/bash
# 研究生小众概念每日推送 v5
# 每天 22:00 执行：用 openclaw infer model 生成三段式故事 → 推送飞书 → 更新记录

OPENCLAW_JSON="/Users/edy/.openclaw/openclaw.json"
CONCEPTS_FILE="/Users/edy/.openclaw/workspace/memory/grad-school-concepts.md"
LOG="/Users/edy/.openclaw/workspace/.backup.log"

# 读取memory文件中最近用过的概念（取最后5个）
recent=$(grep "^| " "$CONCEPTS_FILE" 2>/dev/null | awk -F'|' '{print $4}' | tr -d ' \r' | tail -5 | tr '\n' '|')

# 概念库（与 SKILL.md 保持同步，至少间隔30天才能重用）
# 领域分布：认知/思维、科技/工程、经济/金融、跨学科方法论、物理/工程思维、哲学/社会
declare -a ALL_CONCEPTS=(
  # 认知/思维（10个）
  "幸存者偏差|Survivorship Bias"
  "心智模型|Mental Models"
  "贝叶斯推理|Bayesian Reasoning"
  "确认偏误|Confirmation Bias"
  "锚定效应|Anchoring Effect"
  "可得性启发式|Availability Heuristic"
  "框架效应|Framing Effect"
  "损失厌恶|Loss Aversion"
  "邓宁-克鲁格效应|Dunning-Kruger Effect"
  "事后诸葛亮偏误|Hindsight Bias"
  # 科技/工程（10个）
  "路径依赖|Path Dependence"
  "库梅尔定律|Koomey's Law"
  "黄氏定律|Huang's Law"
  "涌现|Emergence"
  "技术债务|Technical Debt"
  "第二曲线|The Second Curve"
  "寒武纪大爆发|Cambrian Explosion"
  "摩尔定律|Moore's Law"
  "破坏性创新|Disruptive Innovation"
  "网络效应|Network Effect"
  # 经济/金融（8个）
  "能力圈|Circle of Competence"
  "复利效应|Compounding"
  "规模效应|Scaling Law"
  "机会成本|Opportunity Cost"
  "沉没成本|Sunk Cost Effect"
  "棘轮效应|Ratchet Effect"
  "马太效应|Matthew Effect"
  "边际效用递减|Diminishing Marginal Utility"
  # 跨学科方法论（8个）
  "反向推理|Reverse Reasoning"
  "双盲实验|Double-Blind Experiment"
  "信息熵|Information Entropy"
  "归纳偏置|Inductive Bias"
  "控制变量法|Controlled Variable Method"
  "反事实思维|Counterfactual Thinking"
  "模糊逻辑|Fuzzy Logic"
  "复杂系统理论|Complex Systems Theory"
  # 物理/工程思维（6个）
  "熵增原理|Entropy Increase Principle"
  "最小作用量原理|Principle of Least Action"
  "对称性破缺|Symmetry Breaking"
  "相变|Phase Transition"
  "临界现象|Critical Phenomena"
  "普适性|University"
  # 哲学/社会（6个）
  "黑天鹅|Black Swan"
  "反脆弱|Antifragile"
  "林迪效应|Lindy Effect"
  "肥尾分布|Fat-Tail Distribution"
  "修昔底德陷阱|Thucydides Trap"
  "历史终结论|End of History Thesis"
)

pick_random() {
  local available=()
  for c in "${ALL_CONCEPTS[@]}"; do
    name="${c%%|*}"
    if ! echo "$recent" | grep -q "$name"; then
      available+=("$c")
    fi
  done
  if [ ${#available[@]} -eq 0 ]; then
    available=("${ALL_CONCEPTS[@]}")
  fi
  local idx=$((RANDOM % ${#available[@]}))
  echo "${available[$idx]}"
}

chosen=$(pick_random)
concept_name=$(echo "$chosen" | cut -d'|' -f1)
concept_en=$(echo "$chosen" | cut -d'|' -f2)

echo "$(date '+%Y-%m-%d %H:%M:%S') Starting: $concept_name ($concept_en)" >> "$LOG"

# 构造 prompt
PROMPT="你是【研究生小众概念】栏目的编辑，为概念\"${concept_name}（${concept_en}）\"写一篇三段式睡前故事。

要求：
1. 标题格式：Day N | ${concept_name}（${concept_en}）
2. 一句话核心理解（不透露概念名）
3. 三段故事（引入→深入发现→升华），每段150-200字，场景具体，人物有名字，故事里不能出现概念名称或术语
4. 揭晓概念及2-3句说明
5. 故事与概念对照表（表格形式，3行）
6. 一个具体例子
7. 为什么高级（3点）
8. 结尾：明晚同一时间，再送你一个 🍎

严格按以上格式输出，直接输出故事内容。"

# 生成内容（捕获 stdout 和 stderr，openclaw 输出在 stderr 但结果在 stdout）
content=$(openclaw infer model run --model minimax/MiniMax-M2.7 --prompt "$PROMPT" 2>&1 | tail -n +5)

if [ -z "$content" ] || [ ${#content} -lt 50 ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') Generation failed or too short, skipping" >> "$LOG"
  echo "Content was: $content"
  exit 1
fi

# 用 Python 发送飞书
python3 << EOF
import json, urllib.request

with open('$OPENCLAW_JSON') as f:
    cfg = json.load(f)
feishu = cfg['channels']['feishu']

# Get tenant token
req = urllib.request.Request(
    'https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal',
    data=json.dumps({'app_id': feishu['appId'], 'app_secret': feishu['appSecret']}).encode(),
    headers={'Content-Type': 'application/json'}
)
with urllib.request.urlopen(req, timeout=10) as resp:
    token_data = json.loads(resp.read())
tenant_token = token_data.get('tenant_access_token', '')

# Send message
msg = '''${content}'''

send_req = urllib.request.Request(
    'https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=open_id',
    data=json.dumps({
        'receive_id': 'ou_2ad19bb3863e71e2d0eff5cc4aeedd83',
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
        print('SEND_OK')
    else:
        print('SEND_FAIL:', result.get('msg'))
EOF

send_result=$?

# 更新追踪文件
today=$(date '+%Y-%m-%d')
echo "| $today | $concept_name | $concept_en | 0 |" >> "$CONCEPTS_FILE"

echo "$(date '+%Y-%m-%d %H:%M:%S') Done: $concept_name (send=$send_result)" >> "$LOG"
