#!/usr/bin/env bash
# 每日天气推送脚本 - 每天22:30推送到飞书，预报次日天气

CONFIG_FILE="$HOME/.openclaw/openclaw.json"
USER_OPEN_ID="ou_2ad19bb3863e71e2d0eff5cc4aeedd83"

weather_code_to_cn() {
    local code=$1
    case $code in
        113) echo "晴" ;;
        116) echo "多云" ;;
        119) echo "阴" ;;
        122|143) echo "雾" ;;
        176|185|200|227|230|248|260|263|266|281|284|293|296|299|302|305|308|311|314|317|320|323|326|329|332|335|338|350|353|356|359|362|365|368|371|374|377) echo "雨" ;;
        389|392) echo "雷阵雨" ;;
        *) echo "多云" ;;
    esac
}

wind_dir_to_cn() {
    local deg=$1
    if   [[ $deg -ge 338 ]] || [[ $deg -lt 23 ]]; then echo "北风"
    elif [[ $deg -lt 68 ]]; then echo "东北风"
    elif [[ $deg -lt 113 ]]; then echo "东风"
    elif [[ $deg -lt 158 ]]; then echo "东南风"
    elif [[ $deg -lt 203 ]]; then echo "南风"
    elif [[ $deg -lt 248 ]]; then echo "西南风"
    elif [[ $deg -lt 293 ]]; then echo "西风"
    else echo "西北风"
    fi
}

get_tenant_token() {
    APP_SECRET=$(python3 -c "import json; d=json.load(open('$CONFIG_FILE')); print(d.get('channels',{}).get('feishu',{}).get('appSecret',''))")
    APP_ID="cli_a93534f5edb85bd3"
    curl -s -X POST "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal" \
        -H "Content-Type: application/json" \
        -d "{\"app_id\":\"$APP_ID\",\"app_secret\":\"$APP_SECRET\"}" \
        | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tenant_access_token',''))"
}

send_feishu() {
    local token="$1"
    local content="$2"
    curl -s -X POST "https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=open_id" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json; charset=utf-8" \
        -d "{\"receive_id\":\"$USER_OPEN_ID\",\"msg_type\":\"text\",\"content\":\"{\\\"text\\\":\\\"$content\\\"}\"}" \
        > /dev/null
}

main() {
    local token
    token=$(get_tenant_token)
    [[ -z "$token" ]] && echo "获取飞书token失败" && exit 1

    local weather_json
    weather_json=$(curl -s "wttr.in/Chengdu?format=j1")
    [[ -z "$weather_json" ]] && echo "获取天气失败" && exit 1

    # 取明天（index=1）的数据
    local weather_code temp_c feels_like_c wind_kph humidity wind_deg precip_mm
    weather_code=$(echo "$weather_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['weather'][1]['hourly'][4]['weatherCode'])")
    temp_c=$(echo "$weather_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['weather'][1]['hourly'][4]['tempC'])")
    feels_like_c=$(echo "$weather_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['weather'][1]['hourly'][4]['FeelsLikeC'])")
    wind_kph=$(echo "$weather_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['weather'][1]['hourly'][4]['windspeedKmph'])")
    humidity=$(echo "$weather_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['weather'][1]['hourly'][4]['humidity'])")
    wind_deg=$(echo "$weather_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['weather'][1]['hourly'][4]['winddirDegree'])")
    precip_mm=$(echo "$weather_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['weather'][1]['hourly'][4]['precipMM'])")

    local weather_cn wind_cn
    weather_cn=$(weather_code_to_cn "$weather_code")
    wind_cn=$(wind_dir_to_cn "$wind_deg")

    local emoji
    case "$weather_cn" in
        晴) emoji="☀️" ;;
        多云) emoji="⛅" ;;
        阴) emoji="☁️" ;;
        雨|雷阵雨) emoji="🌧️" ;;
        雾) emoji="🌫️" ;;
        *) emoji="🌤️" ;;
    esac

    # 明天日期
    local tomorrow_date
    tomorrow_date=$(echo "$weather_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['weather'][1]['date'])")
    local date_display
    date_display=$(date -j -f "%Y-%m-%d" "${tomorrow_date}" "+%m月%d日" 2>/dev/null || date -d "${tomorrow_date}" "+%m月%d日")

    local msg="📍 成都明日天气（${date_display}）
- ${emoji} ${weather_cn}，${temp_c}°C（体感 ${feels_like_c}°C）
- 💨 风速：${wind_cn} ${wind_kph}km/h
- 💧 湿度：${humidity}%
- 🌧️ 降水：${precip_mm}mm"

    if [[ "$weather_cn" == "晴" ]]; then
        msg+="
阳光不错，户外活动挺合适～"
    fi

    send_feishu "$token" "$msg"
    echo "天气推送成功: $msg"
}

main "$@"
