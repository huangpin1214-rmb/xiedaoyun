# Errors

Command failures and integration errors.

---

## [ERR-20260328-001] feishu_bitabel_upload_content_length

**Logged**: 2026-03-28T23:10:00+08:00
**Priority**: high
**Status**: resolved
**Area**: infra

### Summary
飞书 bitable 附件字段上传 API 始终返回 `code: 1061002 params error`

### Error
```
{"code":1061002,"msg":"params error."}
```
各种参数组合都试过：file_type=image/jpeg、parent_type=bitable_file/bitable_image、extra 参数格式等。

### Context
调用 `POST https://open.feishu.cn/open-apis/drive/v1/files/upload_all` 上传图片到多维表格附件字段，token、参数名、extra.bitablePerm 格式全部正确，但 API 一直报 params error。

**错误的 Node.js 写法：**
```javascript
let body = `--${boundary}\r\n...`;
body += fileContent.toString('binary'); // ← 二进制转字符串破坏数据
const bodyLen = Buffer.byteLength(body); // ← 长度计算不准确
```

### Suggested Fix
**正确写法（已验证）：**
```javascript
const headerBuf = Buffer.from(headerString, 'utf-8');
const fileBuf = fs.readFileSync(filePath);
const trailerBuf = Buffer.from(trailerString, 'utf-8');
const totalLen = headerBuf.length + fileBuf.length + trailerBuf.length;
const fullBody = Buffer.concat([headerBuf, fileBuf, trailerBuf]);
```
关键点：
1. header 和 trailer 先转 Buffer，再和文件 Buffer 用 `Buffer.concat` 拼接
2. Content-Length 用分段长度相加计算，不要用 `Buffer.byteLength(body)` 对字符串计算
3. API 报 params error 有时是 Content-Length 与实际 body 不匹配，不是参数本身问题

### Metadata
- Reproducible: yes
- Related Files: /Users/edy/.openclaw/workspace/memory/2026-03-28.md
- See Also: 也记录在 MEMORY.md 飞书 Bitable 附件上传经验

---

## [ERR-20260328-002] feishu_bitable_file_token_preview_404

**Logged**: 2026-03-28T23:13:00+08:00
**Priority**: critical
**Status**: resolved
**Area**: infra

### Summary
飞书云盘 API 上传的 file_token 在 bitable 附件字段中预览显示 404

### Error
上传后 file_token 写入 bitable 记录，附件显示但点击预览是 404 页面

### Context
**问题现象：**
- 用 `drive/v1/files/upload_all` + `parent_type=bitable_file` 上传，返回 file_token
- 把 token 写入 bitable 记录「原图」字段
- 附件图标显示正常，但点击打开是 404

**根本原因：**
飞书有两套独立的文件存储系统：
- 云盘 API（drive/v1/files/upload_all）→ 返回**通用 file_token**，只能在云盘里预览
- bitable 专用 API（drive/v1/files/upload_all + extra.bitablePerm）→ 返回**bitable 专用 token**，才能在附件字段里预览

**教训：**
- API 返回成功 ≠ 附件能正常预览
- 两套系统 token 不通用，工具描述容易让人以为通用

### Suggested Fix
上传到 bitable 附件字段时，必须：
1. 使用 `extra={"bitablePerm":{"tableId":"...","fieldId":"...","recordId":"..."}}` 参数
2. parent_type 用 `bitable_image`（图片）或 `bitable_file`（文件）
3. 不能用云盘的 `bitable_file` parent_type，必须用 extra 里的 bitablePerm

**工具层面：**
- `feishu_doc_media` 工具的 `bitable_upload` action（hidden）自动处理这些
- 当工具不可用时，用 curl 直接调 API 需要手动加 extra.bitablePerm

### Metadata
- Reproducible: yes
- Related Files: /Users/edy/.openclaw/workspace/MEMORY.md, /Users/edy/.openclaw/workspace/memory/2026-03-28.md
- See Also: ERR-20260328-001（晚上又一次踩同样的坑，用 Buffer.concat 解决）

---

## [ERR-20260404-001] Get笔记列表查询慢

**Logged**: 2026-04-04T10:36:00+08:00
**Priority**: medium
**Status**: documented
**Area**: getnote

### Summary
Get笔记列表 API 不支持日期过滤，只能按时间倒序翻页。查"90天前某一天"需要翻完全部笔记。

### Error
Get笔记共 7331 条，从最新往旧翻到 2026-01-04 翻了 36 页才找到，每页 20 条，每次请求间隔 0.2s，耗时约 2 分钟。

### Context
- 列表 API：`GET /open/api/v1/resource/note/list?since_id=0`
- 不支持按日期过滤、不支持按关键词搜索（搜索用 `/recall` 接口）
- 单次请求间隔 0.2s，翻 36 页 ≈ 2 分钟
- 语义搜索接口 `/recall` 更快但只能搜内容，不能按日期查列表

### 教训
1. **查特定日期的笔记**：先用 `/recall` 语义搜索日期关键词（如"1月4日"），比翻列表快得多
2. **翻列表时用后台 process**：耗时长不要在主流程等待，用 `exec background:true` + `process poll`
3. **已知 API 限制 → 换思路**：Get笔记不支持日期过滤，搜索日期相关内容应该用 recall 接口而不是 list

### Suggested Fix
查特定日期的笔记 → 用 recall 接口：
```bash
curl -X POST "https://openapi.biji.com/open/api/v1/resource/recall" \
  -H "Authorization: $API_KEY" \
  -H "X-Client-ID: $CLIENT_ID" \
  -d '{"query":"1月4日","top_k":10}'
```
翻列表（无日期过滤需求时）→ 用后台执行，不阻塞主对话

### Metadata
- Reproducible: N/A（API 限制，非 bug）
- Related: Get笔记 skill installed at /Users/edy/.openclaw/workspace/skills/getnote

---
