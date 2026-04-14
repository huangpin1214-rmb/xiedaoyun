# 图片识别故障排查经验（2026-04-14）

## 问题现象
飞书通道发送图片后：
- 长时间无响应
- OpenClaw 日志报错：`[media-understanding] image: failed reason=Model does not support images`
- image 工具报错：`Unknown model: minimax/MiniMax-V06`

## 根因分析

### 关键发现：V06 ≠ VL-01

| 模型 | 类型 | 说明 |
|------|------|------|
| MiniMax-M2.7 | 文本模型 | 纯文本推理 |
| MiniMax-V06 | 文本模型（带 image 输入字段） | 实际上不支持视觉理解，走标准 chat completions API 会报错 |
| **MiniMax-VL-01** | **视觉模型** | 真正的图片理解模型，走独立 endpoint `/v1/coding_plan/vlm` |

**核心错误：** openclaw.json 里 `imageModel` 配置成了 `MiniMax-V06`，但 V06 文本模型不支持真正的图片理解。

OpenClaw 源码逻辑：
```
V06 → 尝试走 standard chat completions → API 返回 "model 不支持图片"
VL-01 → 走专门的 /v1/coding_plan/vlm 端点 → 正常工作
```

## 解决步骤

1. 读日志定位错误：`gateway.log` 里有 `[media-understanding]` 和 `[tools] image failed`
2. 读 OpenClaw 源码：`media-understanding-provider-*.js` 和 `minimax-vlm-*.js`
3. 发现 `minimaxMediaUnderstandingProvider` 指定的 default model 是 `MiniMax-VL-01`，而不是 V06
4. 修改 `openclaw.json`：
   - `imageModel.primary` 改为 `minimax/MiniMax-VL-01`
   - 在 `models.providers.minimax.models` 里添加 VL-01 条目
5. 重启 Gateway：`openclaw gateway restart`

## 经验教训

**① 套餐宣传 ≠ API 能力**
"支持图像理解"的套餐描述对应的是 VL-01 模型，而不是 V06。V06 虽然在某些接口层面接受 image token，但实际上不能完成图片理解。

**② 看日志要看两层**
- `[media-understanding]` 层：OpenClaw 的图片理解抽象层
- `[tools] image` 层：image 工具的具体实现层
两层都报错，但意义不同。

**③ 怀疑官方文档的准确性**
MiniMax 官方文档对各模型的分类和接口描述有歧义，"全模态订阅"的说法容易误导。实测发现 V06 图像输入字段存在但功能不可用。

**④ 源码是最好的文档**
遇到工具层问题，grep OpenClaw 源码（如 `/usr/local/lib/node_modules/openclaw/dist/`）比猜测和试错更有效率。

## 修复后的配置

```json
// openclaw.json 相关部分
"imageModel": {
  "primary": "minimax/MiniMax-VL-01"
}

// models.providers.minimax.models 需包含：
{ "id": "MiniMax-VL-01", "input": ["text", "image"], ... }
```

## 相关日志关键词
```
[media-understanding] image: failed (0/1) reason=Model does not support images
[tools] image failed: Unknown model: minimax/MiniMax-V06
```

## 相关文件
- 日志：`~/.openclaw/logs/gateway.log`
- 配置：`~/.openclaw/openclaw.json`
- 源码：`/usr/local/lib/node_modules/openclaw/dist/extensions/minimax/`
