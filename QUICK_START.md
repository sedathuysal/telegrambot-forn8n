Telegram bot oluşturdum. Bot mesaj aldığında n8n workflow'a webhook POST isteği atacak. Docker ile çalışacak ve tüm parametreler environment variables aracılığıyla konfigüre edilecek.

## 5 Dakikada Bot Kurulumu

### Gereksinimler
- Docker & Docker Compose kurulu olması
- Telegram Bot Token ([@BotFather](https://t.me/botfather))
- N8N Webhook URL

---

## Adım 1: Bot Token Al

1. Telegram'da **@BotFather** ile chat aç
2. `/newbot` komutunu gönder
3. Bot adını ve kullanıcı adını gir
4. **Token'ı kopyala** (örn: `123456:ABC-DEF...`)

---

## Adım 2: N8N Webhook Hazırla

1. N8N'de yeni workflow oluştur
2. "On webhook call" trigger ekle
3. **Webhook URL'sini kopyala** (örn: `https://n8n.example.com/webhook/telegram`)
4. Workflow'u **publish** et

[Detaylı N8N kurulum → N8N_SETUP.md](N8N_SETUP.md)

---

## Adım 3: Bot Kurulumu

### Windows:
```bash
docker-build.bat
```

### Linux/Mac:
```bash
bash docker-build.sh
```

### Manuel:
```bash
# .env dosyası oluştur
cp .env.example .env

# .env dosyasını düzenle ve şu değişkenleri ekle:
# TELEGRAM_BOT_TOKEN=your_token_here
# N8N_WEBHOOK_URL=your_webhook_url_here

# Bot'u başlat
docker-compose up -d
```

### Portainer ile (Web UI):

📖 [Portainer kurulum rehberi](PORTAINER_QUICK_START.md)

---

## Adım 4: Test Et

### Telegram'da Bot'a Mesaj Gönder
1. Telegram'da bot'unu ara
2. `/start` yaz
3. Mesaj gönder (örn: "Merhaba!")

### Logları Kontrol Et
```bash
docker-compose logs -f telegram-bot
```

**Beklenen çıktı:**
```
INFO - Webhook başarılı: 123456789 - Merhaba!
```

---

## Adım 5: N8N'den Mesaj Gönder (İsteğe Bağlı)

Bot'a N8N workflow'ından mesaj göndermek için:

### cURL ile Test
```bash
curl -X POST http://localhost:5000/send_message \
  -H "Content-Type: application/json" \
  -d '{
    "chat_id": 123456789,
    "message": "N8N'den gelen test mesajı!",
    "parse_mode": "HTML"
  }'
```

### N8N'de HTTP Request Node
- **Method:** POST
- **URL:** `http://telegram-bot:5000/send_message`
- **Body:**
```json
{
  "chat_id": {{ $json.user_id }},
  "message": "İşlem tamamlandı!",
  "parse_mode": "HTML"
}
```

📖 [Detaylı N8N kullanımı → N8N_SEND_MESSAGE.md](N8N_SEND_MESSAGE.md)

---

## Temel Komutlar

```bash
# Bot'u başlat
docker-compose up -d

# Bot'u durdur
docker-compose down

# Logları göster (gerçek zamanlı)
docker-compose logs -f

# Status kontrol
docker-compose ps

# Bot'u yeniden başlat
docker-compose restart
```

---

## Sorun Giderme

### ❌ "Bot başlamıyor"
```bash
docker-compose logs telegram-bot
```
- `.env` dosyası var mı?
- Token doğru mu?
- N8N URL doğru mu?

### ❌ "Webhook bağlantı hataları"
```bash
# Logları ayrıntılı görmek için .env'i düzenle
LOG_LEVEL=DEBUG
```

### ❌ "N8N webhook tetiklenmedi"
- N8N workflow yayınlı mı? (publish)
- URL doğru mu?
- Network erişimi var mı?

---

## Webhook Payload Örneği

Bot'tan N8N'ye gönderilen veri:
```json
{
  "timestamp": "2024-01-15T10:30:45",
  "user_id": 123456789,
  "username": "telegram_user",
  "message": "Merhaba!",
  "first_name": "Ad",
  "chat_id": 123456789
}
```

N8N'de kullan:
```
{{ $json.message }}      → "Merhaba!"
{{ $json.username }}     → "telegram_user"
{{ $json.timestamp }}    → "2024-01-15T10:30:45"
```

---

## Dosya Yapısı

```
telegrambot/
├── bot.py              ← Ana bot kodları
├── config.py           ← Konfigürasyon
├── requirements.txt    ← Bağımlılıklar
├── Dockerfile          ← Docker image
├── docker-compose.yml  ← Docker Compose
├── .env.example        ← Örnek .env
├── .env                ← Gizli değişkenler (git ignore)
└── README.md           ← Detaylı dokümantasyon
```

---

## Environment Değişkenleri

| Değişken | Zorunlu | Örnek |
|----------|---------|-------|
| `TELEGRAM_BOT_TOKEN` | ✅ | `123456:ABC-DEF...` |
| `N8N_WEBHOOK_URL` | ✅ | `https://n8n.example.com/webhook/telegram` |
| `DEBUG` | ❌ | `false` |
| `LOG_LEVEL` | ❌ | `INFO` |
| `REQUEST_TIMEOUT` | ❌ | `10` |

---

## Güvenlik İpuçları

1. ✅ Token'ı `.env` dosyasında sakla
2. ✅ `.env` dosyasını repository'e push etme
3. ✅ HTTPS (HTTP değil!) webhook kullan
4. ✅ Production'da DEBUG modu kapalı tutun
5. ✅ TOKEN'ı hiçkimseyle paylaşma

---

## Next Steps

1. **Webhook Authentication** ekle (API key ile)
2. **Error Handling** ayarla (N8N'de retry)
3. **Monitoring** kur (logları kontrol et)
4. **Multiple Bots** kurabilirsin (birden fazla token)

---

## Yararlı Kaynaklar

### 🐳 Docker & Portainer
- 📖 [Detaylı README](README.md)
- 🎯 [Portainer Hızlı Başlangıç](PORTAINER_QUICK_START.md) ← **Portainer ile deployment**
- 🔑 [Portainer API Token](PORTAINER_TOKEN.md) ← **Script deployment için**
- 📊 [Portainer Advanced Setup](PORTAINER_SETUP.md)

### 🤖 Bot & N8N
- 🔧 [N8N Kurulum Rehberi](N8N_SETUP.md)
- 📤 [N8N'den Mesaj Gönderme](N8N_SEND_MESSAGE.md)
- ⚙️ [Konfigürasyon Örnekleri](CONFIG_EXAMPLES.md)

### 📚 Dış Kaynaklar
- 🐳 [Docker Dokümantasyonu](https://docs.docker.com/)
- 🤖 [Telegram Bot API](https://core.telegram.org/bots/api)
- 🔄 [N8N Dokumentasyonu](https://docs.n8n.io/)
- 🎛️ [Portainer Dokumentasyonu](https://docs.portainer.io/)

---

## İhtiyacın olduğunda:

- **Konfigürasyon:** [CONFIG_EXAMPLES.md](CONFIG_EXAMPLES.md)
- **N8N Setup:** [N8N_SETUP.md](N8N_SETUP.md)
- **Portainer:** [PORTAINER_QUICK_START.md](PORTAINER_QUICK_START.md)
- **Tüm Detaylar:** [README.md](README.md)

---

**✅ Başarılı! Bot hazır ve çalışıyor.**
