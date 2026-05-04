#!/bin/bash
# Docker build ve başlat scripti

set -e

echo "=== Telegram Bot - Docker Setup ==="

# .env dosyası kontrol et
if [ ! -f ".env" ]; then
    echo "⚠️  .env dosyası bulunamadı!"
    echo "Oluşturuluyor..."
    cp .env.example .env
    echo ""
    echo "📝 Lütfen .env dosyasını düzenleyin ve gerekli değişkenleri ekleyin:"
    echo "   - TELEGRAM_BOT_TOKEN"
    echo "   - N8N_WEBHOOK_URL"
    exit 1
fi

# Docker image'ı derle
echo "🔨 Docker image derlemesi başlanıyor..."
docker-compose build

# Container'ı başlat
echo "🚀 Container başlatılıyor..."
docker-compose up -d

# Logları göster
echo ""
echo "✅ Bot başlatıldı!"
echo ""
echo "📊 Logları görmek için:"
echo "   docker-compose logs -f"
echo ""
echo "⏹️  Durdurmak için:"
echo "   docker-compose down"
