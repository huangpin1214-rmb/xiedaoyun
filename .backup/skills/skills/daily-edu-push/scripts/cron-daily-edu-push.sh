#!/bin/bash
# 教育理念每日推送 - Cron 脚本
# 设置：每天早上 8:00 执行
# 使用 openclaw 发送飞书消息

SKILL_DIR="$HOME/.openclaw/workspace/skills/daily-edu-push"
WORKSPACE="$HOME/.openclaw/workspace"

# 日期
TODAY=$(date +%Y-%m-%d)
DAY_COUNT=$(($(date +%j) - $(date -d "2026-03-29" +%j) + 1))

# 读取当前薄弱点
if [ -f "$WORKSPACE/MEMORY.md" ]; then
  WEAK_POINTS=$(grep -A 20 "女儿各科薄弱点" "$WORKSPACE/MEMORY.md" | head -20)
else
  WEAK_POINTS="暂无数据"
fi

# 生成内容（这里由 AI 接管，此处仅作记录）
echo "[$(date)] 教育理念推送已触发" >> "$WORKSPACE/memory/daily-push-log.md"

# AI 处理：
# 1. Tavily 搜索今日教育研究
# 2. 读取 memory/ 最新兮兮动态
# 3. 生成四板块内容
# 4. 通过 message 工具发送飞书
# 5. 记录到 memory/YYYY-MM-DD.md

echo "触发完成，等待 AI 生成并发送..."
