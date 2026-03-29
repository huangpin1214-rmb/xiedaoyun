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
