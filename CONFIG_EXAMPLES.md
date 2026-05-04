# Telegram Bot Konfigürasyon Örnekleri

## Lokal Geliştirme (.env.local)
```env
TELEGRAM_BOT_TOKEN=123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11
N8N_WEBHOOK_URL=http://localhost:5678/webhook/telegram
API_PORT=5000
DEBUG=true
LOG_LEVEL=DEBUG
REQUEST_TIMEOUT=15
```

## Production (.env.production)
```env
TELEGRAM_BOT_TOKEN=123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11
N8N_WEBHOOK_URL=https://n8n.example.com/webhook/telegram
API_PORT=5000
DEBUG=false
LOG_LEVEL=INFO
REQUEST_TIMEOUT=10
```

## Docker Compose Override (docker-compose.override.yml)
```yaml
version: '3.8'

services:
  telegram-bot:
    build:
      context: .
      dockerfile: Dockerfile
    environment:
      DEBUG: "true"
      LOG_LEVEL: DEBUG
    ports:
      - "5000:5000"  # Opsiyonel: debug port
```

## N8N Webhook Ayarı

N8N'de webhook oluşturmak için:

1. Yeni workflow oluştur
2. "Webhook" trigger'ı ekle
3. "Listen on specific events" seç
4. URL'yi kopyala (örneğin: https://n8n.example.com/webhook/telegram)
5. Authorization türünü seç (opsiyonel)
6. Bot'ın .env dosyasına URL'yi ekle

## Payload Özellikleri

### timestamp
- ISO 8601 formatında zaman damgası
- Örnek: `2024-01-15T10:30:45.123456`

### user_id
- Telegram kullanıcı ID'si
- Benzersiz ve değiştirilemez

### username
- Kullanıcının Telegram kullanıcı adı (@user_name)
- Opsiyonel olabilir

### message
- Mesaj metni
- HTML ve URL'ler içerebilir

### raw_update
- Orijinal Telegram API verisi
- Debug ve gelişmiş kullanım için

## Docker İçinde Environment Değişkenleri

Docker Compose aşağıdaki yöntemlerle environment değişkenlerini yükler:

1. `.env` dosyası (en yüksek öncelik)
2. `docker-compose.yml` içindeki `environment` bölümü
3. `env_file` alanında belirtilen dosya

Kullanım sırası:
```yaml
environment:
  - TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}  # .env'den okur
  - DEBUG=${DEBUG:-false}                      # .env'den, yoksa "false"
```

## SSL/TLS Sertifikası ile N8N

HTTPS kullanırken:
```env
N8N_WEBHOOK_URL=https://n8n.example.com/webhook/telegram
# Sertifika doğrulama otomatik yapılır
```

Kendi imzalı sertifika kullanırken:
```env
N8N_WEBHOOK_URL=https://n8n.example.local/webhook/telegram
# requests kütüphanesi varsayılan olarak doğrulama yapar
# Devre dışı bırakmak için bot.py'de kod değişikliği gerekli
```

## Timeout Ayarları

```env
REQUEST_TIMEOUT=10  # 10 saniye
# Daha yüksek değer = daha uzun bekleme (ağır ağlarda)
# Daha düşük değer = daha hızlı hata (hızlı fail)
```

## API Port Ayarları

```env
API_PORT=5000  # Varsayılan port
# N8N'den mesaj göndermek için kullanılan port
# Docker'da: http://telegram-bot:5000
# Localhost'ta: http://localhost:5000
# Custom port:
# API_PORT=8080  # http://localhost:8080
```

## Çoklu Bot Istansı

Aynı N8N'ye birden fazla bot bağlanırken:
```env
# Bot 1
TELEGRAM_BOT_TOKEN=token_1
N8N_WEBHOOK_URL=https://n8n.example.com/webhook/telegram/bot1
API_PORT=5000

# Bot 2
TELEGRAM_BOT_TOKEN=token_2
N8N_WEBHOOK_URL=https://n8n.example.com/webhook/telegram/bot2
API_PORT=5001  # Farklı port
```

## Güvenlik Ipuçları

1. **Token Yönetimi**
   - Token'ı asla paylaşma
   - Repository'e commit etme
   - Sadece `.env` dosyasında sakla

2. **Webhook Güvenliği**
   - HTTPS kullan (HTTP DEĞİL)
   - Firewall kuralları ayarla
   - IP whitelisting yapabilirseniz yapın

3. **Logging**
   - Production'da DEBUG modu kapalı
   - LOG_LEVEL=INFO veya WARNING
   - Hassas veriler log'a yazılmadığından emin ol

4. **Network**
   - Docker network'ü private tut
   - Container'ı gereksiz portlar açık tutma
   - Rate limiting ayarla (gerekirse N8N'de)

## API Endpoints (N8N'den Mesaj Gönderme)

Bot'ta bulunan API endpoint'leri:

```
POST /send_message         - Tek mesaj gönder
POST /send_message_batch   - Birden fazla mesaj gönder
GET  /health              - Sağlık kontrolü
```

### Kullanım Örneği (cURL)

```bash
# Tek mesaj
curl -X POST http://localhost:5000/send_message \
  -H "Content-Type: application/json" \
  -d '{
    "chat_id": 123456789,
    "message": "Test mesajı",
    "parse_mode": "HTML"
  }'

# Toplu mesaj
curl -X POST http://localhost:5000/send_message_batch \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"chat_id": 123, "message": "Mesaj 1"},
      {"chat_id": 456, "message": "Mesaj 2"}
    ]
  }'
```

**Detaylı Bilgi:** [N8N_SEND_MESSAGE.md](N8N_SEND_MESSAGE.md)
