@echo off
REM Docker build ve baslatma scripti (Windows)

setlocal enabledelayedexpansion

echo === Telegram Bot - Docker Setup ===

REM .env dosyası kontrol et
if not exist ".env" (
    echo .env dosyasi bulunamadi!
    echo Olusturuluyor...
    copy .env.example .env
    echo.
    echo Lutfen .env dosyasini duzenleyin ve gerekli degiskenleri ekleyin:
    echo    - TELEGRAM_BOT_TOKEN
    echo    - N8N_WEBHOOK_URL
    exit /b 1
)

REM Docker image'ı derle
echo Derlemesi baslanıyor...
docker-compose build

REM Container'ı başlat
echo Container baslatiliyor...
docker-compose up -d

REM Logları göster
echo.
echo Bot baslatildi!
echo.
echo Logları gormek icin:
echo    docker-compose logs -f
echo.
echo Durdurmak icin:
echo    docker-compose down
echo.

pause
