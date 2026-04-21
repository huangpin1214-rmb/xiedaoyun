#!/bin/bash
# Get笔记 联通性检查脚本
# 用法: bash getnote-health-check.sh

API_KEY="gk_live_79414cc5d34021a6.f48b009c9ed9470d05fbec8f4ef919f4d657e7a15d91347a"
CLIENT_ID="cli_a1b2c3d4e5f6789012345678abcdef90"
BASE_URL="https://openapi.biji.com"

echo "🔍 检查 Get笔记 API 联通性..."
echo ""

# 测试语义搜索
result=$(curl -s --connect-timeout 8 \
  -H "Authorization: $API_KEY" \
  -H "X-Client-ID: $CLIENT_ID" \
  -H "Content-Type: application/json" \
  "$BASE_URL/open/api/v1/resource/recall" \
  -X POST \
  -d '{"query":"health check","top_k":1}')

success=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin).get('success','error'))" 2>/dev/null)

if [ "$success" = "True" ]; then
  echo "✅ API 联通正常"
  
  # 检查知识库数量
  kb_result=$(curl -s --connect-timeout 8 \
    -H "Authorization: $API_KEY" \
    -H "X-Client-ID: $CLIENT_ID" \
    "$BASE_URL/open/api/v1/resource/knowledge/list?page=1")
  kb_count=$(echo "$kb_result" | python3 -c "import sys,json; print(len(json.load(sys.stdin).get('data',{}).get('topics',[])))" 2>/dev/null)
  echo "✅ 知识库数量: $kb_count"
  
  # 检查订阅知识库
  sub_result=$(curl -s --connect-timeout 8 \
    -H "Authorization: $API_KEY" \
    -H "X-Client-ID: $CLIENT_ID" \
    "$BASE_URL/open/api/v1/resource/knowledge/subscribe/list?page=1")
  sub_count=$(echo "$sub_result" | python3 -c "import sys,json; print(len(json.load(sys.stdin).get('data',{}).get('topics',[])))" 2>/dev/null)
  echo "✅ 订阅知识库数量: $sub_count"
  
  echo ""
  echo "🎉 GetNotes 全部正常，可以操作"
else
  echo "❌ API 调用失败"
  echo "返回: $result"
  exit 1
fi
