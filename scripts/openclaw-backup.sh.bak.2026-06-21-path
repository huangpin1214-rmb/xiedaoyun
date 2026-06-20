#!/bin/bash
# openclaw-backup.sh - 每天备份 OpenClaw 关键配置文件 + 推送到 GitHub
# 使用方法: 系统 crontab 0 3 * * * 自动跑
#
# === 2026-06-20 修复要点（频哥拍 A1）===
# - 排除 sessions 大目录：避免 tar.gz 超 GitHub 100MB（实测 6-20 已 120M 失败）
# - 修复 Python heredoc bug：之前 fail 分支 $PUSH_RESULT 变量丢失，飞书通知 0 发出
# - git-lfs 已配：tar.gz 走 lfs，未来即使涨到 2GB 也不卡 GitHub 100MB
# - 加 .gitignore 排除 sessions：避免 backup/memory 累积 sessions jsonl
# - 加 git pull --rebase：避免 ahead 4 commits 卡住 push

WORKSPACE="$HOME/.openclaw/workspace"
BACKUP_DIR="$WORKSPACE/.backup"
OPENCLAW_DIR="$HOME/.openclaw"
LOG_FILE="$WORKSPACE/.backup.log"
DATE=$(date +%Y-%m-%d)

echo "📦 开始备份... $DATE"

# 清理旧备份
rm -rf "$BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# ===== OpenClaw 配置文件（不含 node_modules） =====
echo "📁 备份 OpenClaw 配置..."
mkdir -p "$BACKUP_DIR/openclaw"
cp "$OPENCLAW_DIR/openclaw.json" "$BACKUP_DIR/openclaw/"
cp "$OPENCLAW_DIR/exec-approvals.json" "$BACKUP_DIR/openclaw/" 2>/dev/null
cp "$OPENCLAW_DIR/wechat-access-auth.json" "$BACKUP_DIR/openclaw/" 2>/dev/null

# 备份关键目录（排除 sessions 大目录：6-20 实测 agents/tech_ops/sessions 单 agent 就 294M）
# 排除 device-auth.json 敏感文件
for dir in identity credentials agents subagents; do
  if [ -d "$OPENCLAW_DIR/$dir" ]; then
    mkdir -p "$BACKUP_DIR/openclaw/$dir"
    # 用 rsync 排除 sessions 和 device-auth.json（比 cp -r + find 删除更高效）
    rsync -a --exclude='*/sessions' --exclude='*/sessions/*' --exclude='device-auth.json' \
          "$OPENCLAW_DIR/$dir/" "$BACKUP_DIR/openclaw/$dir/" 2>/dev/null \
      || cp -r "$OPENCLAW_DIR/$dir"/* "$BACKUP_DIR/openclaw/$dir/" 2>/dev/null
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

# ===== Workspaces（所有 agent 工作空间） =====
echo "📁 备份 Workspaces..."
mkdir -p "$BACKUP_DIR/workspaces"
cp -r "$OPENCLAW_DIR/workspaces" "$BACKUP_DIR/workspaces/" 2>/dev/null

# ===== 打包成 tar.gz =====
cd "$BACKUP_DIR"
echo "📦 打包..."
BACKUP_TAR="$WORKSPACE/openclaw_backup_${DATE}.tar.gz"
tar -czf "$BACKUP_TAR" openclaw skills memory workspaces 2>/dev/null
TAR_SIZE=$(du -h "$BACKUP_TAR" | cut -f1)
TAR_BYTES=$(stat -f%z "$BACKUP_TAR" 2>/dev/null || stat -c%s "$BACKUP_TAR" 2>/dev/null)
echo "📦 打包完成: $TAR_SIZE ($TAR_BYTES bytes)"

# 检查 tar.gz 大小（防御性：即使瘦身后仍有意外膨胀）
if [ "$TAR_BYTES" -gt 95000000 ]; then
  echo "⚠️ tar.gz 接近 100MB，需要检查 sessions 排除是否生效"
fi

# ===== Git 操作 =====
cd "$WORKSPACE"
echo "📝 提交变更..."

# 提交打包文件 + .gitignore + 脚本 + .gitattributes（git-lfs 配置）
git add ".gitattributes" 2>/dev/null
git add "openclaw_backup_${DATE}.tar.gz" .gitignore scripts/ -f

# 单独提交 memory 增量，方便查看变化
git add "memory/" "workspaces/" -f
git commit -m "backup: $DATE" --quiet 2>/dev/null

# 推送（先 rebase 避免 ahead 累积）
echo "🚀 推送到 GitHub..."
git pull --rebase origin main 2>/dev/null
PUSH_RESULT=$(git push origin main 2>&1)
PUSH_EXIT=$?

# ===== 发送飞书通知 =====
# 2026-06-20 修复：原 Python heredoc bug 是 fail 分支 $PUSH_RESULT 传递丢失
# 改成提前导出 shell 变量给 Python，避免 NameError
export BACKUP_STATUS="$PUSH_EXIT"
export BACKUP_DETAIL="$PUSH_RESULT"
export BACKUP_TAR_NAME="openclaw_backup_${DATE}.tar.gz"
export BACKUP_TAR_SIZE_HUMAN="$TAR_SIZE"

send_notify() {
    python3 << 'PYEOF'
import os, json, subprocess, sys, datetime

APP_ID = "cli_a93534f5edb85bd3"
CONFIG_FILE = os.path.expanduser("~/.openclaw/openclaw.json")
USER_OPEN_ID = "ou_2ad19bb3863e71e2d0eff5cc4aeedd83"

# 读 shell 导出的环境变量（避免 heredoc 内 $status 字符串冲突）
push_exit = int(os.environ.get("BACKUP_STATUS", "0"))
detail = os.environ.get("BACKUP_DETAIL", "")
tar_name = os.environ.get("BACKUP_TAR_NAME", "openclaw_backup_unknown.tar.gz")
tar_size = os.environ.get("BACKUP_TAR_SIZE_HUMAN", "?")

# 拿 tenant_access_token
with open(CONFIG_FILE) as f:
    cfg = json.load(f)
feishu_cfg = cfg.get("channels", {}).get("feishu", {})
APP_SECRET = feishu_cfg.get("appSecret", "")

result = subprocess.run(
    ["curl", "-s", "-X", "POST",
     "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal",
     "-H", "Content-Type: application/json",
     "-d", json.dumps({"app_id": APP_ID, "app_secret": APP_SECRET})],
    capture_output=True, text=True, timeout=30
)
try:
    token_data = json.loads(result.stdout)
    app_token = token_data.get("tenant_access_token", "")
except Exception as e:
    print(f"[backup-notify] 解析 token 失败: {e}", file=sys.stderr)
    app_token = ""

if not app_token:
    print("[backup-notify] 获取 token 失败，跳过通知")
    sys.exit(0)

now_str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
date_str = now_str[:10]

# 关键修复：用真实 push_exit 判断，不用字符串模糊匹配
if push_exit == 0:
    msg = f"📦 定时备份报告\n\n✅ GitHub 推送成功\n⏰ 时间：{now_str}\n📦 备份包：{tar_name}\n📦 大小：{tar_size}\n📁 memory/ 单独 commit，可查看每日变化\n💾 git-lfs 已启用，大文件自动走 lfs"
else:
    # 截断 detail 避免飞书消息超长
    detail_short = detail[:300] if detail else "（无错误信息）"
    msg = f"📦 定时备份报告\n\n❌ 备份失败\n⏰ 时间：{now_str}\n📦 备份包：{tar_name}\n📦 大小：{tar_size}\n📌 原因：{detail_short}\n💡 需要手动补跑，请联系谢道韫"

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
    capture_output=True, text=True, timeout=30
)
print(f"[backup-notify] 飞书通知已发送（push_exit={push_exit}）")
PYEOF
}

if [ $PUSH_EXIT -ne 0 ]; then
    echo "❌ 备份失败: $PUSH_RESULT" | tee -a "$LOG_FILE"
    send_notify
    exit 1
fi

echo "✅ 备份完成: $(date)" | tee -a "$LOG_FILE"
send_notify