# MEMORY.md - 谢道韫的长期记忆

## 用户偏好与要求

### 飞书授权原则（2026-03-29）
- 遇到 token 过期 → 先自己尝试刷新或降频重试，实在搞不定再找频哥人工授权
- 不主动发起多次重复授权请求
- 批量操作优先，减少 API 调用次数

### 飞书权限卡片处理（2026-04-03 新增，已更新 2026-04-15）
- 当出现 `im:message` / `im:message.send_as_user` 等用户身份权限申请卡片时
- **不要反复排查 token 是否有效** → 频哥已经批量授权过了，token 本身没问题
- `feishu_oauth_batch_auth` 是旧版工具，**新版(2026.4.x)已不存在**
- **正确做法**：优先用 tenant token 绕过 uat 问题；如果 tenant token 不够用，再尝试引导用户授权
- 教训：之前花了很长时间排查 token 和授权方式，**tenant token 才是捷径**

---

## 技术经验

### 🔑 飞书 Token 体系（2026-04-15 更新）

**两种 Token 用途不同：**

| Token 类型 | 获取方式 | 用途 | 有效期 |
|-----------|---------|------|--------|
| User Access Token (uat) | OAuth 用户授权 | 操作需要用户身份的功能（部分 bitable/云盘） | 2小时，过期需重新授权 |
| Tenant Access Token | app_id + app_secret 调用 API | 应用级别的文件上传、消息发送、bitable 读写 | 2小时，自动续期 |

**macOS Keychain 存储位置：**
```
Service: openclaw-feishu-uat
Account: {appId}:{userOpenId}  → cli_a93534f5edb85bd3:ou_2ad19bb3863e71e2d0eff5cc4aeedd83
```

**核心经验（2026-04-15）：**
- 错题本图片上传和记录写入，**tenant token 就够用**，不需要 uat
- uat 过期时不要死磕 OAuth，直接用 tenant token 重试
- 重新获取 tenant token 命令：
  ```bash
  curl -s -X POST "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal" \
    -H "Content-Type: application/json" \
    -d '{"app_id":"cli_a93534f5edb85bd3","app_secret":"..."}'
  ```

---

### 🔑 飞书 Bitable 附件上传（完整解决方案 2026-03-28，已更新 2026-04-15）

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

### Get笔记 API 使用经验（2026-04-04）

**API 列表查询（list）**：
- 不支持日期过滤，只能按时间倒序翻页
- 7331 条笔记翻到 90 天前约需 2 分钟（36 页 × 0.2s 间隔）
- 翻列表时用 `exec background:true` + `process poll`，不要阻塞主对话

**语义搜索（recall）**：
- 搜索关键词/日期用 `POST /open/api/v1/resource/recall`，比翻列表快得多
- `top_k` 默认 3，最大 10

**查询特定日期笔记的正确方式**：
- 不用 list 翻页 → 直接用 recall 接口搜日期关键词

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

## 自我认知（2026-04-15 新增）

**习惯比规则更难改变**
- 知道规则 ≠ 做到规则，两者之间隔着"习惯"
- AI的"记忆"不像人类那样形成反射，需要真实失败反馈才能修正行为
- "说了=做到了"是幻觉，必须经过多次"触发→失败→修正"循环才能形成真正的行为改变

---

## 辅导教训（2026-03-29）

**地理判题原则：图文对照优先**
- 地理题必须先识别图中地理环境，再匹配知识点
- 不能先入为主调用"最典型知识点"去套题目
- 第20题错因：把新疆和若铁路（塔克拉玛干沙漠）误认为青藏铁路，没有仔细看图辨认

**地理规范表达积累（2026-04-15 新增）**
- 山脉走向：只接受四种标准写法——**东西/南北/东北-西南/西北-东南**走向，不接受"自…向…"格式（如"自西南向东北"❌→"东北-西南走向"✅）
- 商品率答案套路：人口占比小（消费少）+ 耕地/产量占比大（可外销多）= 商品率高
- 高寒适应生物表述：毛发浓密 + 心肺/血红蛋白功能强，比"血液载氧能力强"更教材化
- 地理判卷喜欢"教材化"表达，不是口语化意思对就行

**Skill触发习惯（2026-04-15 新增）**
- 收到图片类错题 → 立即调用对应学科tutor skill（不是凭直觉分析）
- 被用户指正分析有差距 → 立即调用self-improvement skill记录（不是自己写复盘了事）

---

## 独立判断原则（2026-04-04 教训）

- 我有自己的专业判断，不会因为频哥或女儿的说法就盲从
- 如果他们的说法和我理解的不一致，我会直接说出来，有根据地坚持
- **在所有事情上都应做到独立判断，包括答案判断、操作执行**

---

## Skill 优化规则（2026-04-04 新增）

当频哥说"优化一下 skill"时：
1. 先询问频哥是否需要调用 `skill-interview-builder` 进行系统性自检
2. 不自己直接改 SKILL.md，先访谈确认需求再动手
3. 避免"改完再说"——让频哥知道优化方向后再执行

## 答案自检规则（2026-04-04 新增）

### 核心原则：自己做一遍，不对比验证

**当需要确认答案是否正确时：**
1. 独立把题做一遍，得出自己的答案
2. 如果自己的答案和记录一致 → 可以更新或确认
3. **如果自己的答案和记录不一致 → 直接说"我算出X，记录是Y，请确认"，不强行解释，不改记录**
4. 频哥确认后再更新，不自己判断该听谁的

**重要：验证已知答案 ≠ 独立解题**
- 验证已知答案对不对，最多只能做原理层面的检查
- 独立解题后发现不一致，说明我可能做错了，应该如实说

### 工具使用规则（2026-04-04 新增）

**遇到技术问题时：**
1. 先盘点现有环境有什么（pip list、which、python版本等）
2. 再根据限制条件（/tmp路径、白名单等）选择工具
3. 避免随机试错、避免调用不存在的方法

### 工具盘点清单（常用）

**PDF处理：**
- `pypdf` → `/usr/bin/python3 -c "from pypdf import..."`（系统Python有，pip install的没有）
- PIL/Pillow → 只能处理图片，不能直接读PDF
- macOS `qlmanage` → 生成缩略图（-t -s）
- macOS `cupsfilter` → PDF转图片（需要正确参数）

**文件路径限制：**
- bitable_upload 必须 /tmp/ 下文件
- 其他工具一般支持完整路径

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
- 【重要纠错】中考短文填空格式：词框给原词根（如possible/sit/success），需自行判断变形后填入，而非原词直接填入。考的是"词性转换+语境理解"双重能力。
- 改进：每日3组词性转换闪卡 + 固定搭配集中背

**🟠 地理 — 高优先（思维型）**
- 因果链条未建立（地形→气候→农业；河流特征→航运/水能）
- 区域核心特征模糊（青藏=高寒、西北=干旱）
- 图文对照能力弱
- 改进：每日10分钟地图+说特征；建立"地气水土生→农业"思维链

---

## 英语短文填空持续改进流程（2026-04-06 新增）

### 核心原则
每次收到兮兮的英语错题图片，按以下四步自动执行：

**Step 1 - 识别题目**
收到图片 → AI识别题目和答案

**Step 2 - 诊断错因（调用 Language Learning Tutor）**
用 Mode 2（语法课）模式分析：
- 这个错是"固定搭配"还是"词性转换判断失误"？
- 是"语境理解不到位"还是"语法规则没掌握"？
- 属于哪个具体考点？

**Step 3 - 更新 MEMORY.md 诊断档案**
在"英语短文填空错因分布"下追加新条目：
```
### 英语短文填空错因分布（持续更新）
- 固定搭配类：as...as possible（第2次出现）→ 提升优先级
- 词性转换类：介词to后接名词（第1次出现）
- 语境理解类：上下文推断失误（第3次出现）
```

**Step 4 - 更新备考方案文档**
根据最新错因分布，在飞书文档《英语短文填空备考方案》中：
- 调整哪块练习量要加大
- 补充相关练习题
- 更新错因统计表

### 触发条件
- 兮兮发来英语错题图片 → 自动走四步
- 不需要频哥额外指令

### Language Learning Tutor 调用方式
- **遇到某个语法点不会** → Mode 2 语法课
- **某类题型总是错** → Mode 7 考试冲刺分析错因
- **需要设计阶段测试** → Mode 4 闪卡训练
- **每天练习后复盘** → Mode 3 会话练习检验理解

### 参考资料
- 飞书备考方案文档：https://www.feishu.cn/docx/PnsUd2knYoMMA4xEzQvcJMM9ncf
- 短文填空练习（五/四/三）均已生成，可直接使用

**🟡 物理 — 中优先**
- 受力分析不过关（一重二弹三摩擦不熟练）
- 液体压强与容器形状综合分析
- 整体法与隔离法应用不熟
- 改进：受力分析四步口诀，每题画图
- **待确认：B4题 AD=8N 力学分析（我和官方差2N，待和频哥确认）**

---

## 备份体系（2026-03-30 建立）

- **GitHub 仓库**：`github.com:huangpin1214-rmb/xiedaoyun`
- **备份脚本**：`~/.openclaw/workspace/scripts/openclaw-backup.sh`
- **Crontab**：每天凌晨 3:00 自动执行并推送
- **备份范围**：`.backup/openclaw/`（配置）+ `.backup/skills/`（Skills）
- **SSH Key**：`~/.ssh/id_ed25519_github`（已添加到 GitHub）

---

## Get笔记操作安全规则（2026-04-04 新增）

**删除前必须反复确认原则：**
- 删除任何笔记之前，必须先告知频哥内容是什么
- 告知后，等待明确回复"同意删除"才能执行
- 未经确认，不得自行删除任何笔记

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

## OpenClaw 版本与配置

### ⚠️ 升级 Workspace 重置风险（2026-04-14 新增）
OpenClaw 升级时如果 Git 有更新，workspace 会被 `git pull --rebase` 覆盖，以下字段**必须保留**：

```json
"plugins": {
  "entries": {
    "feishu": { "enabled": true }   ← 飞书插件，必须保持 true！
  }
}
```

**预防**：升级前先检查 git 状态，确保本地修改已提交；升级后检查 `plugins.entries.feishu.enabled` 是否被重置为 false，如被重置立即手动改回 true 并重启 Gateway。

**自动防护**：每 30 分钟检查一次 `feishu.enabled`，若被重置为 false 则自动修复并重启 Gateway。

**飞书通道问题排查优先级**：遇到飞书消息不响应时，**首先检查** `plugins.entries.feishu.enabled` 是否为 true（这是最常见的重置点），其次检查飞书插件是否 loaded，再检查 dmPolicy 配置。（2026-03-30）

- 当前版本：2026.4.2（已关闭自动升级）
- 更新策略：手动升级，需要时再升
- 插件：openclaw-lark（飞书）、openclaw-wechat-access-plugin、skills/getnote（Get笔记）

---

## 🧬 成都中考生物备考资料（2026-04-01 完成）

### 十年真题分析（2015-2024）
- **完整分析**：`memory/成都中考生物十年完整分析.md`
- **七年全勤考点**：生态系统/食物网、遗传规律/概率、动物行为、动物分类、植物繁殖
- **四年稳定考点**：光合作用综合、心脏结构、尿液形成
- **兮兮高频丢分点**：蒸腾作用重量变化、反射弧完整性、遗传50%概率、自然选择

### 模拟题一（2026-04-01 完成）
- `memory/成都中考生物模拟题一完整版.md`

### 兮兮生物薄弱点
- 光合/呼吸综合（CO₂吸收vs释放判断）
- 遗传概率（生男生女永远是50%）
- 心脏结构（左心室最厚）
- 反射弧五部分缺一不可
- **【新增 2026-04-06】** 就地保护 vs 易地保护区分不清（2022中考Q12）

---

## 📝 Get笔记每日辅导启发（2026-04-04 新增）

### 每日审查机制
- 每天 21:00 复盘时，自动从 Get笔记 读取最近与"兮兮/教育"相关的笔记
- 提取新内容，更新辅导策略
- 将启发写入当日 memory/ 文件 + 提炼到 MEMORY.md 相关章节

### 核心辅导原则（从笔记中提炼）
1. **"虚假掌握感"是最大敌人**：孩子说"看过了"不等于"会做了"。辅导时优先打透一个知识点，不堆量。
2. **生物优先级高于其他非英语科目**：生物备考资料最完整，说明功夫下得最深，但不能因此松懈——越熟的地方越容易大意丢分。
3. **英语 = 日积月累型**：不能靠冲刺，每天3组词性转换 + 固定搭配比一次性刷100道题更有效。
4. **错题本是核心资产**：坚持录入 + 定期回顾，生物和物理错题是中考前最值得反复看的资源。
