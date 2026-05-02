#!/bin/bash
# 教育理念每日推送 - Cron 脚本
# 设置：每天早上 8:00 执行
# 使用 openclaw 发送飞书消息

SKILL_DIR="$HOME/.openclaw/workspace/skills/daily-edu-push"
WORKSPACE="$HOME/.openclaw/workspace"

# 日期（macOS 兼容，避免八进制问题）
TODAY=$(date +%Y-%m-%d)
START_DATE="2026-03-29"
START_DAY_OF_YEAR=$(date -j -f "%Y-%m-%d" "$START_DATE" +%j 2>/dev/null || date -d "$START_DATE" +%j 2>/dev/null)
CURRENT_DAY_OF_YEAR=$(date +%j)
# 去掉前导0避免八进制解释
START_DAY_OF_YEAR=$((10#$START_DAY_OF_YEAR))
CURRENT_DAY_OF_YEAR=$((10#$CURRENT_DAY_OF_YEAR))
DAY_COUNT=$(($CURRENT_DAY_OF_YEAR - $START_DAY_OF_YEAR + 1))

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
