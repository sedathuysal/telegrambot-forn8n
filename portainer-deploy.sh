#!/bin/bash
# Portainer'a Telegram Bot Deploy Scripti

set -e

echo "========================================="
echo "  Telegram Bot - Portainer Deploy"
echo "========================================="
echo ""

# Kontrol
if [ -z "$PORTAINER_URL" ]; then
    echo "⚠️  PORTAINER_URL tanımlanmadı"
    echo "Kullanım: PORTAINER_URL=http://localhost:9000 bash portainer-deploy.sh"
    exit 1
fi

if [ -z "$PORTAINER_TOKEN" ]; then
    echo "⚠️  PORTAINER_TOKEN tanımlanmadı"
    echo "Portainer'dan access token al: Admin → Users → API tokens"
    exit 1
fi

STACK_NAME="telegram-bot"
ENDPOINT_ID="1"  # Docker endpoint ID (genellikle 1)

# .env dosyası kontrol et
if [ ! -f ".env" ]; then
    echo "❌ .env dosyası bulunamadı!"
    echo "Çözüm: cp .env.example .env ve doldur"
    exit 1
fi

# Environment değişkenlerini oku
export $(cat .env | xargs)

echo "📝 Stack Bilgileri:"
echo "  Name: $STACK_NAME"
echo "  Portainer URL: $PORTAINER_URL"
echo "  Bot Token: ${TELEGRAM_BOT_TOKEN:0:10}***"
echo "  N8N Webhook: ${N8N_WEBHOOK_URL:0:30}***"
echo ""

# Docker Compose dosyasını hazırla
COMPOSE_CONTENT=$(cat docker-compose.yml)

# Stack payload oluştur
PAYLOAD=$(cat <<EOF
{
  "Name": "$STACK_NAME",
  "StackFileContent": "$(echo "$COMPOSE_CONTENT" | sed 's/"/\\"/g' | tr '\n' ' ')",
  "Env": [
    {"name": "TELEGRAM_BOT_TOKEN", "value": "$TELEGRAM_BOT_TOKEN"},
    {"name": "N8N_WEBHOOK_URL", "value": "$N8N_WEBHOOK_URL"},
    {"name": "API_PORT", "value": "${API_PORT:-5000}"},
    {"name": "DEBUG", "value": "${DEBUG:-false}"},
    {"name": "LOG_LEVEL", "value": "${LOG_LEVEL:-INFO}"},
    {"name": "REQUEST_TIMEOUT", "value": "${REQUEST_TIMEOUT:-10}"}
  ]
}
EOF
)

# Stack zaten var mı kontrol et
echo "🔍 Stack durumu kontrol ediliyor..."
STACK_ID=$(curl -s -X GET "$PORTAINER_URL/api/stacks?name=$STACK_NAME" \
  -H "Authorization: Bearer $PORTAINER_TOKEN" | grep -o '"Id":[0-9]*' | head -1 | grep -o '[0-9]*' || echo "")

if [ -z "$STACK_ID" ]; then
    echo "✅ Yeni stack oluşturuluyor..."
    
    # Yeni stack oluştur
    RESPONSE=$(curl -s -X POST "$PORTAINER_URL/api/stacks?type=2&method=string&endpointId=$ENDPOINT_ID" \
      -H "Authorization: Bearer $PORTAINER_TOKEN" \
      -H "Content-Type: application/json" \
      -d "$PAYLOAD")
    
    STACK_ID=$(echo "$RESPONSE" | grep -o '"Id":[0-9]*' | grep -o '[0-9]*')
    
    if [ -z "$STACK_ID" ]; then
        echo "❌ Stack oluşturma başarısız!"
        echo "$RESPONSE"
        exit 1
    fi
    
    echo "✅ Stack oluşturuldu! ID: $STACK_ID"
else
    echo "⚠️  Stack zaten var (ID: $STACK_ID)"
    echo "Güncellemek için: portainer-deploy.sh update"
fi

echo ""
echo "✅ Deploy başarılı!"
echo ""
echo "📊 Portainer URL: $PORTAINER_URL"
echo "📦 Stack: $STACK_NAME"
echo "🆔 Stack ID: $STACK_ID"
echo ""
echo "Sonraki adımlar:"
echo "  1. Portainer'a giriş yap: $PORTAINER_URL"
echo "  2. Stacks → $STACK_NAME → view in compose"
echo "  3. Containers → telegram-bot → logs"
echo ""
