#!/bin/bash
# openclaw-backup.sh - 每天备份 OpenClaw 关键配置文件
# 使用方法: 加入 crontab: 0 3 * * * /Users/edy/.openclaw/workspace/scripts/openclaw-backup.sh

WORKSPACE="$HOME/.openclaw/workspace"
BACKUP_DIR="$WORKSPACE/.backup"
OPENCLAW_DIR="$HOME/.openclaw"

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

# ===== Git 操作 =====
cd "$WORKSPACE"
echo "📝 提交变更..."
git add .backup/ .gitignore scripts/ -f
git commit -m "backup: $(date +%Y-%m-%d\ %H:%M)" --quiet 2>/dev/null

# 推送
echo "🚀 推送到 GitHub..."
git push origin main 2>&1

echo "✅ 备份完成: $(date)"
