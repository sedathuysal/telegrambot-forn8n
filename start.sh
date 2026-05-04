#!/bin/bash
# Local geliştirme için bot başlatma scripti

echo "=== Telegram Bot Başlatılıyor ==="

# Python sürümü kontrol et
python_version=$(python3 --version 2>&1 | awk '{print $2}')
echo "Python sürümü: $python_version"

# Virtual environment kontrol et
if [ ! -d "venv" ]; then
    echo "Virtual environment oluşturuluyor..."
    python3 -m venv venv
fi

# Virtual environment'i aktif et
source venv/bin/activate

# Bağımlılıkları yükle
echo "Bağımlılıklar yükleniyor..."
pip install -r requirements.txt

# .env dosyası kontrol et
if [ ! -f ".env" ]; then
    echo ".env dosyası oluşturuluyor..."
    cp .env.example .env
    echo "⚠️  .env dosyasını düzenleyin ve bot token'ı ekleyin"
    exit 1
fi

# Bot'u başlat
echo "Bot başlatılıyor..."
python3 bot.py
