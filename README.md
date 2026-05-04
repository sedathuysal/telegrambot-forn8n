# Telegram Bot - N8N Webhook İntegrasyonu

Telegram mesajlarını N8N workflow'a gönderen bot.

## 📋 Özellikler

- ✅ Telegram mesajlarını almak
- ✅ N8N webhook'a otomatik POST isteği
- ✅ N8N'den bot'a mesaj gönderme (API endpoint'leri)
- ✅ Tekli ve toplu mesaj gönderme
- ✅ Environment değişkenleri ile konfigürasyon
- ✅ Docker desteği
- ✅ Hata yönetimi ve logging

## 🚀 Hızlı Başlangıç

### Ön Koşullar

- Docker & Docker Compose (veya Portainer)
- Telegram Bot Token ([@BotFather](https://t.me/botfather)'dan)
- N8N Webhook URL

### Kurulum

#### Docker Compose ile (Önerilen)

1. **Repository'yi klonla**
```bash
cd telegrambot
```

2. **.env dosyası oluştur**
```bash
cp .env.example .env
```

3. **.env dosyasını düzenle**
```env
TELEGRAM_BOT_TOKEN=your_bot_token_here
N8N_WEBHOOK_URL=https://your-n8n-instance.com/webhook/telegram
```

4. **Docker ile başlat**
```bash
docker-compose up -d
```

#### Portainer ile (Web UI)

1. [Portainer kurulum rehberini gör](PORTAINER_QUICK_START.md)
2. Portainer UI: http://localhost:9000
3. Stacks → Add Stack → docker-compose.yml yapıştır
4. Environment variables ekle ve deploy et

**[Detaylı Portainer rehberi →](PORTAINER_SETUP.md)**
```bash
cp .env.example .env
```

3. **.env dosyasını düzenle**
```env
TELEGRAM_BOT_TOKEN=your_bot_token_here
N8N_WEBHOOK_URL=https://your-n8n-instance.com/webhook/telegram
```

4. **Docker ile başlat**
```bash
docker-compose up -d
```

## 📝 Dosya Yapısı

```
telegrambot/
├── bot.py                 # Ana bot kodları
├── config.py              # Konfigürasyon ve environment değişkenleri
├── requirements.txt       # Python bağımlılıkları
├── Dockerfile             # Docker image tanımı
├── docker-compose.yml     # Docker Compose konfigürasyonu
├── .env.example           # Örnek environment dosyası
├── .gitignore            # Git ignore kuralları
└── README.md             # Bu dosya
```

## 🔧 Konfigürasyon

### Environment Değişkenleri

| Değişken | Açıklama | Zorunlu |
|----------|----------|---------|
| `TELEGRAM_BOT_TOKEN` | Telegram bot token'ı | ✅ Evet |
| `N8N_WEBHOOK_URL` | N8N webhook URL'si | ✅ Evet |
| `API_PORT` | API Sunucusu Port'u | ❌ Hayır (varsayılan: 5000) |
| `DEBUG` | Debug modu (true/false) | ❌ Hayır |
| `LOG_LEVEL` | Log seviyesi (DEBUG, INFO, WARNING, ERROR) | ❌ Hayır |
| `REQUEST_TIMEOUT` | İstek zaman aşımı (saniye) | ❌ Hayır |

## 🐳 Docker Komutları

### Başlat
```bash
docker-compose up -d
```

### Durdur
```bash
docker-compose down
```

### Logları görüntüle
```bash
docker-compose logs -f telegram-bot
```

### Yeniden başlat
```bash
docker-compose restart
```

## 📤 Webhook Payload Örneği

N8N'ye gönderilen veri yapısı:

```json
{
  "timestamp": "2024-01-15T10:30:45.123456",
  "user_id": 123456789,
  "username": "telegram_username",
  "first_name": "Ad",
  "last_name": "Soyad",
  "chat_id": 123456789,
  "message_type": "text",
  "message": "Mesaj içeriği",
  "raw_update": {
    "message_id": 1,
    "chat_id": 123456789,
    "date": "2024-01-15T10:30:45"
  }
}
```

## � API Endpoints (N8N'den Mesaj Gönderme)

Bot'a N8N'den mesaj göndermek için API endpoint'lerini kullanın.

### `/send_message` - Tek Mesaj Gönder

**POST** `http://localhost:5000/send_message`

```json
{
  "chat_id": 123456789,
  "message": "Merhaba! Bu bir test mesajıdır.",
  "parse_mode": "HTML"
}
```

### `/send_message_batch` - Toplu Mesaj Gönder

**POST** `http://localhost:5000/send_message_batch`

```json
{
  "messages": [
    {"chat_id": 123, "message": "Mesaj 1"},
    {"chat_id": 456, "message": "Mesaj 2"}
  ]
}
```

### `/health` - Sağlık Kontrolü

**GET** `http://localhost:5000/health`

✅ Detaylı bilgi: [N8N_SEND_MESSAGE.md](N8N_SEND_MESSAGE.md)

## �🔐 Güvenlik İpuçları

1. `.env` dosyasını asla repository'e push etme
2. Bot token'ını gizli tut
3. Production'da HTTPS kullan
4. Webhook URL'sini güvenli tutun
5. API endpoint'lerine erişimi sınırla (firewall kuralları)

## 📝 Loglar

Bot loglar `stdout`'a yazıyor. Docker loglarını görmek için:

```bash
docker-compose logs -f
```

Log seviyeleri:
- `DEBUG`: Detaylı debug bilgileri
- `INFO`: Genel bilgi mesajları
- `WARNING`: Uyarı mesajları
- `ERROR`: Hata mesajları
- `CRITICAL`: Kritik hatalar

## 🐛 Sorun Giderme

### Bot başlamıyor
- `.env` dosyasının var olup olmadığını kontrol et
- Token ve URL'nin doğru olduğunu kontrol et

### Webhook hatası
- N8N webhook URL'sinin doğru olduğunu kontrol et
- Ağ bağlantısını kontrol et
- N8N'de webhook'un aktif olduğunu kontrol et

### Log hatası
```bash
docker-compose logs telegram-bot
```

## 📚 İlgili Kaynaklar

### Proje Dokümantasyonu
- [QUICK_START.md](QUICK_START.md) - 5 dakikada başlangıç
- [N8N_SETUP.md](N8N_SETUP.md) - N8N webhook kurulumu
- [N8N_SEND_MESSAGE.md](N8N_SEND_MESSAGE.md) - **N8N'den mesaj gönderme API** 
- [CONFIG_EXAMPLES.md](CONFIG_EXAMPLES.md) - Konfigürasyon örnekleri
- **[PORTAINER_QUICK_START.md](PORTAINER_QUICK_START.md) - Portainer kurulumu ve deployment** 🆕
- **[PORTAINER_SETUP.md](PORTAINER_SETUP.md) - Advanced Portainer yapılandırması** 🆕

### Harici Kaynaklar
- [python-telegram-bot Dokumentasyonu](https://python-telegram-bot.readthedocs.io/)
- [N8N Dokumentasyonu](https://docs.n8n.io/)
- [Docker Dokumentasyonu](https://docs.docker.com/)
- [Portainer Dokumentasyonu](https://docs.portainer.io/)
- [Telegram Bot API](https://core.telegram.org/bots/api)

## 📄 Lisans

MIT License

## 👤 Yardım

Sorularınız veya önerileriniz için lütfen issue açınız.
