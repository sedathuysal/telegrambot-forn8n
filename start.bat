@echo off
echo === Telegram Bot Baslatiliyor ===

REM Python versiyonunu kontrol et
python --version >nul 2>&1
if errorlevel 1 (
    echo Hata: Python yüklü değil!
    exit /b 1
)

REM Virtual environment kontrol et
if not exist "venv" (
    echo Virtual environment olusturuluyor...
    python -m venv venv
)

REM Virtual environment'i aktif et
call venv\Scripts\activate.bat

REM Bagimlilikları yükle
echo Bagimliliklar yukleniyor...
pip install -r requirements.txt

REM .env dosyası kontrol et
if not exist ".env" (
    echo .env dosyası olusturuluyor...
    copy .env.example .env
    echo !! .env dosyasini duzenleyin ve bot token'ı ekleyin
    exit /b 1
)

REM Bot'u başlat
echo Bot baslatiliyor...
python bot.py

pause
