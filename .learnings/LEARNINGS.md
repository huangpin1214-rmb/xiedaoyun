# Learnings

Corrections, insights, and knowledge gaps captured during development.

**Categories**: correction | insight | knowledge_gap | best_practice

---

## [LRN-20260507-001] insight

**Logged**: 2026-05-07T07:25:00+08:00
**Priority**: medium
**Status**: pending
**Area**: config

### Summary
OpenClaw Skills 自动更新报告 ≠ Agent 主动更新，不要混为一谈

### Details
频哥看到 "Skills自动更新报告 | 05月07日 06:00" 通知后，以为我主动执行了更新操作，问我"更新了哪个skill"。但实际上：
1. 这是 OpenClaw 每天定时检查 ClawHub 的自动同步任务，不是我的操作
2. `git status` 显示的 modification 是系统自动同步留下的本地状态
3. 我需要明确区分「系统自动同步」和「我主动更新」这两个概念

### Suggested Action
当用户提到"skill 更新"时，先确认来源：
- 如果是 OpenClaw 系统通知 → 说明是每日自动同步
- 如果是我主动更新 → 说明我执行了什么操作
不应该在没确认来源的情况下，默认用户指的是我的操作。

### Metadata
- Source: user_feedback
- Related Files: skills/*
- Tags: skill-update, communication, clarity
- See Also: LRN-20260426-003 (执行承诺固化)

---

## [LRN-20260507-002] correction

**Logged**: 2026-05-07T07:28:00+08:00
**Priority**: medium
**Status**: pending
**Area**: config

### Summary
用户提到具体时间点时，应先确认该时间点的信息来源再回答

### Details
频哥问"那你6点钟反馈的有更新是什么意思？"——这个时间点（06:00）是关键线索。但我在没有确认"6点钟的反馈"具体指什么的情况下，直接开始检查 git status，错误地认为"频哥在问我看到了哪些 modification"。实际上那些 modification 是系统自动同步的结果，与我无关。

正确做法：
1. 看到时间戳时，先确认"6点钟"对应的具体事件/通知
2. 如果用户指"Skills自动更新报告"通知，说明这是系统自动同步，不是我的主动操作
3. 承认"我"的范围：只包括我实际执行的操作，系统自动任务不应混为一谈

### Suggested Action
当用户提到时间点（"6点钟"）时，主动确认： "你说的6点钟是指 Skills 自动更新报告那个通知吗？"

### Metadata
- Source: user_feedback
- Tags: clarification, communication, skill-update
- See Also: LRN-20260507-001

---