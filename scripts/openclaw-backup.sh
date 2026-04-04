#!/bin/bash
# openclaw-backup.sh - 每天备份 OpenClaw 关键配置文件
# 使用方法: 加入 crontab: 0 3 * * * /Users/edy/.openclaw/workspace/scripts/openclaw-backup.sh

WORKSPACE="$HOME/.openclaw/workspace"
BACKUP_DIR="$WORKSPACE/.backup"
OPENCLAW_DIR="$HOME/.openclaw"
LOG_FILE="$WORKSPACE/.backup.log"
STATUS="✅ 备份成功"

echo "📦 开始备份... $(date)"

# 清理旧备份
rm -rf "$BACKUP_DIR"

# ===== OpenClaw 配置文件（不含 node_modules） =====
echo "📁 备份 OpenClaw 配置..."
mkdir -p "$BACKUP_DIR/openclaw"
cp "$OPENCLAW_DIR/openclaw.json" "$BACKUP_DIR/openclaw/"
cp "$OPENCLAW_DIR/exec-approvals.json" "$BACKUP_DIR/openclaw/" 2>/dev/null
cp "$OPENCLAW_DIR/wechat-access-auth.json" "$BACKUP_DIR/openclaw/" 2>/dev/null

# 备份关键目录（排除 node_modules）
for dir in identity credentials agents subagents; do
  if [ -d "$OPENCLAW_DIR/$dir" ]; then
    mkdir -p "$BACKUP_DIR/openclaw/$dir"
    cp -r "$OPENCLAW_DIR/$dir"/* "$BACKUP_DIR/openclaw/$dir/" 2>/dev/null
  fi
done

# ===== Skills（用户创建的） =====
echo "📁 备份 Skills..."
mkdir -p "$BACKUP_DIR/skills"
cp -r "$WORKSPACE/skills" "$BACKUP_DIR/skills/" 2>/dev/null
cp "$WORKSPACE"/*.skill "$BACKUP_DIR/skills/" 2>/dev/null

# ===== memory 文件（对话记录、每日分析） =====
echo "📁 备份 memory..."
mkdir -p "$BACKUP_DIR/memory"
cp -r "$WORKSPACE/memory" "$BACKUP_DIR/memory/" 2>/dev/null

# ===== Git 操作 =====
cd "$WORKSPACE"
echo "📝 提交变更..."
git add .backup/ .gitignore scripts/ memory/ -f
git commit -m "backup: $(date +%Y-%m-%d\ %H:%M)" --quiet 2>/dev/null

# 推送
echo "🚀 推送到 GitHub..."
PUSH_RESULT=$(git push origin main 2>&1)
PUSH_EXIT=$?

if [ $PUSH_EXIT -ne 0 ]; then
    STATUS="❌ 备份失败"
    echo "$STATUS: $PUSH_RESULT" | tee -a "$LOG_FILE"
    exit 1
fi

echo "✅ 备份完成: $(date)" | tee -a "$LOG_FILE"

# ===== 发送飞书通知 =====
python3 << 'PYEOF'
import subprocess, json, sys, os

# 飞书应用配置 - 从 openclaw.json 读取
APP_ID = "cli_a93534f5edb85bd3"
CONFIG_FILE = os.path.expanduser("~/.openclaw/openclaw.json")
with open(CONFIG_FILE) as f:
    feishu_cfg = json.load(f).get("channels", {}).get("feishu", {})
APP_SECRET = feishu_cfg.get("appSecret", "")

USER_OPEN_ID = "ou_2ad19bb3863e71e2d0eff5cc4aeedd83"

# 获取 app_access_token
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

# 发送消息
import datetime
now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
msg = f"📦 定时备份报告\n\n✅ GitHub 推送成功\n⏰ 时间：{now}\n📁 备份内容：配置、Skills、memory"

result = subprocess.run(
    ["curl", "-s", "-X", "POST",
     "https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=open_id",
     "-H", f"Authorization: Bearer {app_token}",
     "-H", "Content-Type: application/json",
     "-d", json.dumps({
         "receive_id": USER_OPEN_ID,
         "msg_type": "text",
         "content": json.dumps({"text": msg})
     })],
    capture_output=True, text=True
)
print("飞书通知已发送")
PYEOF
