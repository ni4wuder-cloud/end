#!/bin/bash
# 每次重開 ngrok 之後，跑一下這支腳本，把目前的 wss:// 網址寫進 ngrok-url.json
# quiz.html 開啟時會自動讀這個檔案、自動填入連線欄位並連線，不用手動複製貼上
#
# 用法： ./update-ngrok-url.sh

set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

HTTPS_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | python3 -c "
import json, sys
data = json.load(sys.stdin)
tunnels = data.get('tunnels', [])
for t in tunnels:
    if t.get('proto') == 'https':
        print(t['public_url'])
        break
")

if [ -z "$HTTPS_URL" ]; then
  echo "找不到 ngrok tunnel，請先確認 ngrok 有在跑（ngrok http 9001）"
  exit 1
fi

WSS_URL="${HTTPS_URL/https:\/\//wss://}"

cat > "$DIR/ngrok-url.json" <<EOF
{"wss_url": "$WSS_URL", "updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"}
EOF

echo "已更新：$WSS_URL"
echo "寫入：$DIR/ngrok-url.json"
