# Learnings

Corrections, insights, and knowledge gaps captured during development.

**Categories**: correction | insight | knowledge_gap | best_practice

---

## [LRN-20260328-001] best_practice

**Logged**: 2026-03-28T23:10:00+08:00
**Priority**: medium
**Status**: pending
**Area**: docs

### Summary
成都中考地理 2016-2024 九年真题已系统录入地理导师 skill，形成高频考点库

### Details
频哥提供了女儿初二地理中考复习资料，我录入了2016-2024年共9年成都中考地理真题的核心考点到地理导师 skill。

**收录情况：**
- 2016：简录版（秦岭淮河、成都干湿区、成昆铁路）
- 2017：完整版（地球运动、夏至直射、黄土高原）
- 2018：完整版（南极科考站、一带一路、三江源）
- 2019：完整版（粤港澳大湾区、罗斯海新站）
- 2020：完整版（国家地理位置、台湾红桧、珠峰测量）
- 2021-2024：完整版（各有侧重）

**高频考点汇总：**
- 南极科考站（几乎每年）
- 地球公转/自转（每年）
- 秦岭淮河一线（高频）
- 黄土高原水土流失（多次）
- 北京城市职能（多次）
- 长江/黄河（多次）
- 四大地理分区（核心）

### Suggested Action
出题/辅导时直接调用 skill 参考这些真题规律

### Metadata
- Source: conversation
- Related Files: /Users/edy/.openclaw/workspace/skills/geography-tutor/SKILL.md
- Tags: geography, chengdu-gaokao, skill-building

---

## [LRN-20260328-002] best_practice

**Logged**: 2026-03-28T23:10:00+08:00
**Priority**: medium
**Status**: pending
**Area**: config

### Summary
女儿喜欢周深，用周深语气辅导效果更好；频哥还没告诉我女儿最喜欢哪些具体内容

### Details
频哥的女儿初二，喜欢周深（歌手），希望我辅导时用周深的语气交流。

**已收集的周深特点：**
- 说话风格：温柔、真诚、有点害羞但幽默、声音空灵温暖
- 代表作：《大鱼》《起风了》《和光同尘》
- 绰号：卡布叻（b站）、人工客服（爱回复粉丝）、怼怼、周浅
- 金句："一个人的成功永远不可能是一个人的功劳"；"我不是天才，我是努力型"
- 辅导比喻：音色独特→找到自己特点；努力型→天赋不够努力来凑

**待确认：**
频哥说要去问女儿最喜欢周深哪些歌/故事，还没回复

### Suggested Action
等频哥回复后更新 USER.md，届时辅导更有针对性

### Metadata
- Source: conversation
- Related Files: /Users/edy/.openclaw/workspace/USER.md
- Tags: tutoring, zhou-shen, daughter

---

## [LRN-20260404-001] correction

**Logged**: 2026-04-04T21:45:00+08:00
**Priority**: high
**Status**: pending
**Area**: tutoring

### Summary
答案不能来回改，根源是没有独立判断；物理自检时我自己做B1/B4/23-1三道题都出错

### Details
**事件："
答案改了三遍"现象**
- 第10题改了三遍，越改越没把握，根源是：没有独立判断，每次都是看到"好像不对"就改，而不是真的想清楚
- 改进：自己做一遍再对照，不一致时直接报给频哥确认，不强行解释

**物理自检失败教训**
- 我自检 B1、B4、23-1 三道题，都和原始记录不一致
- 事后分析：我是在"验证已知答案"而不是"独立解题"，这两件事本质不同
- 验证已知答案：只能做原理层面检查，不能重新做一遍
- 独立解题后发现不一致：如实说"我算出X，记录Y，请确认"

### Suggested Action
独立判断 + 不改记录：自己做一遍，不一致就报给频哥，不强行统一

### Metadata
- Source: self_review
- Tags: tutoring, answer-checking, self-discipline

---

## [LRN-20260404-002] best_practice

**Logged**: 2026-04-04T21:45:00+08:00
**Priority**: medium
**Status**: pending
**Area**: infra

### Summary
PDF处理：系统Python的pypdf可用，pip install的反而没有；工具使用前先盘点环境

### Details
今天调了7-8种PDF处理方法失败，最终发现：
- `/usr/bin/python3`（系统Python）有 `pypdf` 库，可用
- `pip install` 的反而没有

**工具使用规则**：先盘点环境，再选择工具，避免随机试错

### Metadata
- Source: error
- Tags: pdf, python, environment-check

---

## [LRN-20260328-003] best_practice

**Logged**: 2026-03-28T23:10:00+08:00
**Priority**: medium
**Status**: pending
**Area**: infra

### Summary
AI 图像生成模型无法可靠渲染中文标签，SVG→QLManage→PNG 是更可靠的出图方案

### Details
为初二生物辅导出图时，测试了多种 AI 图生图模型（Minimax等），中英文标签均随机乱码，这是底层模型限制，无法通过提示词解决。

**已验证可行的方案（生物模式图）：**
1. 用 SVG 手绘标注图（文字用 `<text>` 标签，无乱码）
2. 用 macOS qlmanage 命令转 PNG：
   ```bash
   qlmanage -t -s 800 -o /tmp/ photosynthesis.svg
   # 输出 /tmp/photosynthesis.svg.png
   ```
3. 发送图片给用户

**结论：**
- 生物（模式图）→ SVG 方案可行
- 地理（真实地图）→ SVG 地图地理数据不准确，改用用户提供教材照片
- AI 生成图片：废弃，所有模型均无法可靠渲染文字

### Suggested Action
生物出图题用 SVG 方案；地理图让频哥提供教材照片

### Metadata
- Source: error
- Related Files: /Users/edy/.openclaw/workspace/memory/2026-03-28.md
- Tags: image-generation, svg, biology, fix-validated

---

## [LRN-20260328-004] best_practice

**Logged**: 2026-03-28T23:13:00+08:00
**Priority**: high
**Status**: promoted
**Area**: infra

### Summary
飞书两套文件存储系统：云盘 API token vs bitable 专用 API token，工具描述不等于工具能力

### Details
早上解决图片上传问题时发现：

**两套系统的区别：**

| API | Endpoint | 返回 token | 用途 |
|-----|----------|------------|------|
| 云盘 API | `drive/v1/files/upload_all` | 通用 file_token | 云盘查看 |
| Bitable 专用 API | 同 endpoint + `extra.bitablePerm` | bitable 专用 token | 附件字段预览 |

**经验教训：**
1. API 文档描述可能有歧义，要主动读源码
2. `feishu_doc_media` 工具的 description 一开始没有写明 `bitable_upload` 这个 hidden action，是读源码才发现的
3. Gateway 重启后工具可能不可用（工具注册机制不稳定）
4. 最终找到稳定方案：直接从 Keychain 拿 user access_token → 调 upload_all API → 拿 token → 更新记录

**源码重要性：**
工具描述 ≠ 工具实际能力。当描述不完整时，去读 `$OPENCLAW_EXT/.../doc-media.js` 可能有意想不到的收获。

### Metadata
- Source: error
- Related Files: /Users/edy/.openclaw/workspace/MEMORY.md
- Tags: feishu, api, token-system, source-code
- See Also: ERR-20260328-002

---

## [LRN-20260329-001] correction

**Logged**: 2026-03-29T11:21:00+08:00
**Priority**: high
**Status**: pending
**Area**: knowledge_gap

### Summary
地理"以桥代路"第20题判错，正确答案是B（②③④），不是A；错因是先入为主调用"青藏铁路藏羚羊"这个典型知识点，没有仔细看图辨认甲路段是新疆和若铁路

### Details
**事件：**
频哥发来地理练习题，第20题问"以桥代路"原因叙述正确的是（），我判为A（含①藏羚羊通道），并录入错题本。后经频哥提醒看图，发现甲路段不是青藏铁路而是**新疆和若铁路**（和田—若羌），位于塔克拉玛干沙漠边缘，首要目的是防风沙，不是藏羚羊通道。

**错误思维链：**
1. 看到"以桥代路" → 调用"青藏铁路藏羚羊通道"这个最典型的储备知识
2. 先入为主，强行把①匹配给甲
3. 看到选项有含①的组合就觉得①是对的
4. 没有仔细看图辨认每个路段到底是什么铁路

**正确分析：**
- 甲（新疆和若铁路）：防风沙（不是藏羚羊）
- 乙（青藏铁路）：冻土 + 藏羚羊
- 丙（湖南高速）：少占耕地
- 丁（贵州大桥）：提高直达性和运行安全
- 正确答案：**B（②③④）** — 女儿做对了！

### Suggested Action
地理题必须先图文对照，再匹配知识点；不再先入为主从教材知识点倒推答案。每次做题前先用模型识别图中地理环境特征。

### Metadata
- Source: user_feedback
- Tags: geography, error-reasoning, 图文对照
- See Also: LRN-20260328-004（飞书相关知识）

---
