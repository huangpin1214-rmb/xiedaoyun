# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

## Script Creation - Execute Permission (2026-04-18)

`write` tool and `cp` create files with 644 permissions (rw-r--r--), **no execute bit**.

**Problem:** Scripts without execute permission fail silently in crontab:
```
Permission denied
```

**Rule:** After creating any script via `write`/`cp` that will be run by crontab, always `chmod +x /path/to/script.sh`.

**Better approach:** Use `exec` with heredoc + chmod in one step:
```bash
cat > /path/to/script.sh << 'EOF'
#!/bin/bash
...
EOF
chmod +x /path/to/script.sh
```

---

## Get笔记 快速参考（2026-04-21 新增）

### ✅ 当前状态（2026-04-21 验证）
- API 域名：`https://openapi.biji.com`（正确）
- API Key：`gk_live_79414cc5d34021a6...`（有效）
- Client ID：`cli_a1b2c3d4e5f6789012345678abcdef90`（有效）
- 联通状态：✅ 正常

### ⚠️ 常见错误
- ❌ `api.note.moe` — 这个域名 DNS 解析不了，**永远不要用**
- ✅ `openapi.biji.com` — 正确域名

### 🔑 认证 Header
```
Authorization: gk_live_79414cc5d34021a6.f48b009c9ed9470d05fbec8f4ef919f4d657e7a15d91347a
X-Client-ID: cli_a1b2c3d4e5f6789012345678abcdef90
Content-Type: application/json
```

### 🔧 快速测试脚本
```python
python3 -c "
import urllib.request, json
api_key = 'gk_live_79414cc5d34021a6.f48b009c9ed9470d05fbec8f4ef919f4d657e7a15d91347a'
client_id = 'cli_a1b2c3d4e5f6789012345678abcdef90'
url = 'https://openapi.biji.com/open/api/v1/resource/recall'
data = json.dumps({'query':'test','top_k':1}).encode()
req = urllib.request.Request(url, data=data, headers={'Content-Type':'application/json','Authorization':api_key,'X-Client-ID':client_id})
with urllib.request.urlopen(req, timeout=10) as resp:
    r = json.loads(resp.read())
    print('API状态:', '正常' if r.get('success') else '异常')
"
```

## 日期查询规则（2026-04-22 新增）

**⚠️ 日期必须从消息元数据获取，禁止凭记忆推算**

当被问到「明天是几号」「后天呢」等相对日期时：
1. **不要用 session_status** —— 它的输出里没有今天日期（只显示时间和用量）
2. **从消息 metadata 的 timestamp 字段读取真实日期**
   - 元数据格式：`Wed 2026-04-22 22:51 GMT+8`
   - 这是每次消息都有的真实时间戳
3. 基于真实日期推算「明天」「后天」

**这个错误已经犯了3次**，必须形成反射：被问到日期 → 立即看消息 timestamp → 推算 → 回答

---

### 📋 操作优先级规则
1. **优先读 SKILL.md**：`skills/getnote/SKILL.md` 是操作 GetNotes 的**第一权威**
2. **不要凭记忆调用 API** — 先读 SKILL.md 的指令路由表
3. **操作失败时**：先用上面的「快速测试脚本」确认 API 联通性
4. **域名/配置问题**：不要反复试，直接读 SKILL.md 确认正确参数
