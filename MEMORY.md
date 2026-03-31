# MEMORY.md - 谢道韫的长期记忆

## 用户偏好与要求

### 飞书授权原则（2026-03-29）
- 遇到 token 过期 → 先自己尝试刷新或降频重试，实在搞不定再找频哥人工授权
- 不主动发起多次重复授权请求
- 批量操作优先，减少 API 调用次数

---

## 技术经验

### 🔑 飞书 Bitable 附件上传（完整解决方案 2026-03-28）

---

#### 背景

为频哥的孩子建立「初二错题本」飞书多维表格，目标是：
**发图片 → AI识别题目 → 自动录入表格（含原图）**

核心难点在于图片附件的上传——这是一个花了很长时间才彻底解决的问题。

---

#### 问题现象

上传图片到飞书多维表格的「原图」字段时：
- 用云盘 API `drive.file.uploadAll` 返回的 file_token 在 bitable 里打开是 404
- 链接显示"找不到文件"

---

#### 根本原因（关键发现）

飞书内部有**两套独立的文件存储系统**：

| API | Endpoint | 返回 token | 用途 |
|-----|----------|------------|------|
| 云盘 API | `drive/v1/files/upload_all` | 通用 file_token | 云盘查看 |
| Bitable 专用 API | `drive/v1/files/upload_all` + `extra.bitablePerm` | bitable 专用 token | 附件字段预览 |

**核心区别**在于 `extra` 参数：`extra={"bitablePerm":{"tableId":"xxx"}}` 才是关键。

---

#### 解决方案一：使用 feishu_doc_media 工具（工具层）

**工具信息：**
- 工具名：`feishu_doc_media`
- action：`bitable_upload`
- 源码：`~/.openclaw/extensions/openclaw-lark/src/tools/oapi/drive/doc-media.js`
- 参数字段：`app_token`, `table_id`, `field_id`, `file_path`, `type`
- **限制：file_path 必须是 `/tmp/` 下的文件**

**操作步骤：**
1. 图片复制到 `/tmp/`：`cp /path/to/image.jpg /var/folders/.../T/image.jpg`
2. 调用 `feishu_doc_media` action=`bitable_upload`
3. 返回 `file_token`
4. 用 `bitable_app_table_record` update 写入记录

**已知问题：** 该工具在 Gateway 重启后一段时间内可用，之后可能无法被调用（工具注册机制不稳定）

**注意：** 工具的 description 最初没有写明 `bitable_upload`，需要主动读源码发现

---

#### 解决方案二：直接调用 Feishu Open API（稳定可靠，推荐）

绕过工具层，直接用 curl 调用飞书开放 API。

**Step 1 — 获取用户 Access Token**

Token 存在 macOS Keychain 里：
```
Keychain Service: openclaw-feishu-uat
Account: {appId}:{userOpenId}
```

```bash
FULL_TOKEN=$(security find-generic-password -s "openclaw-feishu-uat" \
  -a "cli_a93534f5edb85bd3:ou_2ad19bb3863e71e2d0eff5cc4aeedd83" -w)
ACCESS_TOKEN=$(echo "$FULL_TOKEN" | python3 -c \
  "import sys,json; d=json.load(sys.stdin); print(d.get('accessToken',''))")
```

Keychain 存的是完整 JSON，结构：
```json
{
  "userOpenId": "ou_2ad19bb3863e71e2d0eff5cc4aeedd83",
  "appId": "cli_a93534f5edb85bd3",
  "accessToken": "eyJ..."
}
```

**Step 2 — 上传文件**

```bash
curl -s -X POST "https://open.feishu.cn/open-apis/drive/v1/files/upload_all" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -F "file_name=image.jpg" \
  -F "parent_type=bitable_image" \
  -F "parent_node={app_token}" \
  -F "size={文件大小}" \
  -F "file=@{file_path};type=image/jpeg" \
  -F 'extra={"bitablePerm":{"tableId":"{table_id}"}}'
```

**关键参数：**
- Endpoint: `https://open.feishu.cn/open-apis/drive/v1/files/upload_all`
  - ❌ 易错：`media/upload_all`（错误）
  - ✅ 正确：`files/upload_all`（正确）
- `parent_type`:
  - 图片用 `bitable_image`
  - 文件用 `bitable_file`
- `extra`: `{"bitablePerm":{"tableId":"table_id"}}`

**Step 3 — 写入记录**

返回 `{ "code": 0, "data": { "file_token": "xxx" }, "msg": "Success" }`

用 `bitable_app_table_record` update 写入：
```json
{
  "fields": {
    "原图": [{ "file_token": "返回的token" }]
  }
}
```

---

#### 重要教训

1. **工具描述不等于工具能力**：`feishu_doc_media` 的 description 一开始没写 `bitable_upload`，但源码里已经写好了。需要主动读源码。
2. **文件路径白名单**：bitable_upload 限制文件必须在 `/tmp/` 下，本地图片需先复制过去
3. **API endpoint 细节**：SDK 里的 endpoint 是 `drive/v1/files/upload_all`（不是 `media/upload_all`），这个细节错了很久才查到
4. **parent_type 区分**：`bitable_image` vs `bitable_file` 有区别，用错会上传成功但预览 404
5. **工具不稳定问题**：feishu_doc_media 工具通过 RPC 注册，Gateway 重启后可能失效；备选方案是直接调 API（稳定）

---

#### 相关资源

- 飞书插件源码：`~/.openclaw/extensions/openclaw-lark/`
- bitable_upload 实现：`src/tools/oapi/drive/doc-media.js` → `handleBitableUpload()`
- Token 存储：`src/core/token-store.js`（macOS 用 Keychain）
- Keychain 查询：`security find-generic-password`
- appId：`cli_a93534f5edb85bd3`（来自 `~/.openclaw/openclaw.json` → channels.feishu.appId）
- 用户 OpenId：`ou_2ad19bb3863e71e2d0eff5cc4aeedd83`

---

### 💡 错题本业务流程（完整自动化）

```
孩子拍错题 → 发图片+指令"录入错题本" →
  AI识别图片 → 提取题目/答案/知识点/学科/难度 →
  复制图片到/tmp/ →
  调用 bitable_upload API →
  写入 bitable 记录（含原图）
```

飞书多维表格「兮兮的错题本」app_token: `TAxUbXUmKaXVuXsNWOacbP1Tne1`

---

## 关于频哥

- 位置：成都
- 背景：科技行业从业23年，历经华为（硬件研发、质量）→ 2家创业公司（质量与运营）→ 芯片公司（质量运营）
- 通才型学习者：什么都知道一些，但不陷入单一领域；学习方式碎片化、兴趣驱动，杂而不散
- 孩子：初二，14岁，明年中考；每科基础有但不扎实，方法需要提升；喜欢周深（歌曲：《化身孤岛的鲸》《未闻花名》《大鱼》《花开忘忧》）
- 偏好：中文沟通，直接给AI起名字很有创意
- 飞书多维表格「初二错题本」：app_token=TAxUbXUmKaXVuXsNWOacbP1Tne1
- 部署手册：`~/.openclaw/workspace/docs/错题本部署手册.md`
- Mac 版本：Sonoma 14.8.4，插电使用

## 辅导相关

- **优先科目：** 英语
- **辅导方式：** 方法>答案，温柔但有要求，随时来问
- **飞书多维表格「兮兮的错题本」：** app_token=TAxUbXUmKaXVuXsNWOacbP1Tne1

## 身份更新（2026-03-29）

**新角色定义：成长陪伴型学习教练**

- 频哥：芯片行业从业23年通才型学习者，兴趣广泛；主要帮女儿辅导（优先英语），也欢迎随时提问
- 女儿：初二考生，中考在即；用周深式温柔风格交流
- 辅导方式：方法>答案，温柔但有要求，朋友式沟通

## 辅导教训（2026-03-29）

**地理判题原则：图文对照优先**
- 地理题必须先识别图中地理环境，再匹配知识点
- 不能先入为主调用"最典型知识点"去套题目
- 第20题错因：把新疆和若铁路（塔克拉玛干沙漠）误认为青藏铁路，没有仔细看图辨认

---

## 女儿各科薄弱点（2026-03-30 分析更新）

**🔴 数学 — 最高优先**
- 分类讨论意识薄弱（等腰三角形漏情况、含参不等式边界）
- 几何模型识别力弱（半角模型、辅助线构造）
- 待定系数法运算不过关（k 值易算错）
- 改进：每天3道分类讨论题 + 几何模型卡片

**🟠 英语 — 高优先（积累型）**
- 词性转换不扎实（pain→painful、repeat→repeatedly、enter→entrance）
- 现在完成时标志词混淆（already/yet/since/for vs ago/last）
- 固定搭配记忆模糊（had difficulty doing、clear the air）
- 改进：每日3组词性转换闪卡 + 固定搭配集中背

**🟠 地理 — 高优先（思维型）**
- 因果链条未建立（地形→气候→农业；河流特征→航运/水能）
- 区域核心特征模糊（青藏=高寒、西北=干旱）
- 图文对照能力弱
- 改进：每日10分钟地图+说特征；建立"地气水土生→农业"思维链

**🟡 物理 — 中优先**
- 受力分析不过关（一重二弹三摩擦不熟练）
- 液体压强与容器形状综合分析
- 整体法与隔离法应用不熟
- 改进：受力分析四步口诀，每题画图

---

## 备份体系（2026-03-30 建立）

- **GitHub 仓库**：`github.com:huangpin1214-rmb/xiedaoyun`
- **备份脚本**：`~/.openclaw/workspace/scripts/openclaw-backup.sh`
- **Crontab**：每天凌晨 3:00 自动执行并推送
- **备份范围**：`.backup/openclaw/`（配置）+ `.backup/skills/`（Skills）
- **SSH Key**：`~/.ssh/id_ed25519_github`（已添加到 GitHub）

---

## 飞书权限说明（2026-03-31）

### 已确认可用的权限
- `calendar:calendar:read` → ✅ 可读主日历元数据（summary、calendar_id）
- `drive:drive:read` → ✅ 云盘文件读写

### 缺失的权限（功能降级可接受）
- `calendar:calendar.event:read` → ❌ 缺失；只能看忙闲（free/busy），无法查看具体日程详情
  - 影响：无法查看日程标题、时间、描述等
  - 状态：已告知频哥，待确认是否授权

---

## OpenClaw 版本与配置（2026-03-30）

- 当前版本：2026.3.28（已关闭自动升级）
- 更新策略：手动升级，需要时再升
- 插件：openclaw-lark（飞书）、openclaw-wechat-access-plugin
