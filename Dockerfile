FROM python:3.11-slim

# Çalışma dizinini ayarla
WORKDIR /app

# Sistem paketlerini güncelle
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Python bağımlılıklarını kopyala ve yükle
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Uygulama dosyalarını kopyala
COPY config.py .
COPY bot.py .

# .env dosyası çalışma zamanında mount edilecek
# Bkz. docker-compose.yml env_file konfigürasyonu

# Bot'u çalıştır
CMD ["python", "bot.py"]
