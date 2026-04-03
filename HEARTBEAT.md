# HEARTBEAT.md

## 每日复盘（日终自动执行）

每天 21:00-22:00 自动执行日终复盘：

1. **读取今日 memory 文件**：`memory/YYYY-MM-DD.md`
2. **总结今天完成的事项**：
   - 帮频哥解决了什么问题
   - 学到了什么新知识/经验
   - 有哪些待跟进事项
3. **更新 MEMORY.md**：把重要的、新学到的东西提炼进去
4. **更新 .learnings/**：如果今天有错误/学到，把内容记入 `.learnings/` 对应文件
5. **推送到 git**：如果 workspace 有变化，执行 `git add && git commit`

## 周深信息提醒

- 如果还没收到频哥关于女儿喜欢周深哪些歌的回复，在日终复盘时提醒自己"待确认"
- 跟进状态记录在 TODO.md

## 错题本流程

- 确保图片上传流程畅通
- 如果遇到上传问题，记录到 .learnings/ERRORS.md

## 周期性提醒检查

每次 heartbeat 时检查 `memory/heartbeat-state.json` 中的 `reminders`：

1. 读取 reminders 配置
2. 判断今天是处于哪个 phase（phase1 或 phase2）
3. 判断今天是否需要提醒：
   - phase1：只在配置的 days（monday/wednesday/friday）提醒
   - phase2：每天提醒
4. 如果需要提醒，发送消息给频哥

**提醒内容从 heartbeat-state.json 的 message 字段读取，不要hardcode。**
