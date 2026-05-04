# N8N Webhook Kurulum Rehberi

## N8N Webhook Setup

Bot'u N8N ile entegre etmek için adım adım rehber.

### 1. N8N'de Webhook Oluştur

#### Adım 1: Yeni Workflow Başlat
- N8N Dashboard'a git
- "+ Add first step" veya "+" butonuna tıkla

#### Adım 2: Webhook Trigger'ı Seç
- "On webhook call" trigger'ını seç
- Veya "Webhook" search et

#### Adım 3: Webhook URL'sini Al
```
Webhook URL: https://n8n.example.com/webhook/telegram
```

#### Adım 4: Method Ayarı
- Method: `POST` (Bot POST isteği gönderir)
- Authentication: "None" veya API key (güvenlik için)

### 2. Payload Örneği

Bot'tan gelen veri:
```json
{
  "timestamp": "2024-01-15T10:30:45.123456",
  "user_id": 123456789,
  "username": "telegram_user",
  "first_name": "Ad",
  "last_name": "Soyad",
  "chat_id": 123456789,
  "message_type": "text",
  "message": "Selam bot!",
  "raw_update": {
    "message_id": 1,
    "chat_id": 123456789,
    "date": "2024-01-15T10:30:45"
  }
}
```

### 3. Webhook Data Kullanımı

N8N'de webhook datasına erişmek:
```
{{ $json.message }}        // "Selam bot!"
{{ $json.username }}       // "telegram_user"
{{ $json.user_id }}        // 123456789
{{ $json.timestamp }}      // "2024-01-15T10:30:45.123456"
```

### 4. N8N Workflow Örneği

**Basit Echo Workflow:**
1. Webhook (trigger)
2. Function node:
```javascript
return {
  json: {
    reply_message: `${$json.username} tarafından gönderilen mesaj: ${$json.message}`
  }
};
```

**Veritabanına Kaydetme:**
1. Webhook (trigger)
2. PostgreSQL / MongoDB node
3. Mesajı insert et

**Email Gönderme:**
1. Webhook (trigger)
2. Gmail / SendGrid node
3. Bildirimi gönder

### 5. Bot .env Dosyasını Güncelle

```env
TELEGRAM_BOT_TOKEN=your_token
N8N_WEBHOOK_URL=https://n8n.example.com/webhook/telegram
```

### 6. Test Et

1. Bot'u başlat:
```bash
docker-compose up -d
```

2. Telegram'da bot'a mesaj gönder

3. N8N'de webhook loglarını kontrol et

4. Workflow tetiklenmiş mi diye kontrol et

## Hata Ayıklama

### Webhook Tetiklenmiyor

**Kontrol Listesi:**
- [ ] N8N webhook URL'si doğru mu?
- [ ] Bot .env dosyasında URL var mı?
- [ ] N8N webhook aktif mi?
- [ ] Ağ bağlantısı sorun yok mu?

**Log Kontrol:**
```bash
docker-compose logs -f telegram-bot
```

### N8N'de Webhook Görünmüyor

- Workflow'u yayınla (publish)
- Webhook dropdown'ını kapat ve aç
- Page'i yenile
- Browser cache'ini temizle

### Bağlantı Zaman Aşımı

```env
REQUEST_TIMEOUT=20  # Varsayılan 10, değeri arttır
```

### SSL/TLS Hatası

```
SSL: CERTIFICATE_VERIFY_FAILED
```

N8N'de kendi imzalı sertifika kullanırken, `bot.py` içinde düzenle:

```python
# bot.py içinde send_to_webhook fonksiyonunda
response = requests.post(
    self.webhook_url,
    json=payload,
    timeout=self.timeout,
    verify=False,  # SADECE DEVELOPMENT ORTAMINDA!
    headers={"Content-Type": "application/json"}
)
```

**⚠️ NOT:** Production'da `verify=False` YAPMAK GÜVENLIK RİSKİDİR!

## Gelişmiş Özellikler

### 1. Webhook Authentication

N8N'de API key kullan:

```javascript
// N8N Webhook: Authentication ekle
header: Authorization = Bearer your_token
```

Bot'ta:
```python
# bot.py'de
headers={
    "Content-Type": "application/json",
    "Authorization": "Bearer your_token"
}
```

### 2. Retry Logic

N8N'de workflow başarısız olursa:
1. Node ayarlarında "Keep on error" enable et
2. Retry node ekle
3. Error handling workflow oluştur

### 3. Rate Limiting

Çok fazla mesaj gönderilirse:

```env
# Bot tarafında timeout arttır
REQUEST_TIMEOUT=30
```

N8N'de:
- Workflow throttling ayarla
- Queue sistemi ekle
- Database'de rate limit tut

## N8N Webhook Örnekleri

### Örnek 1: Slack'e Gönder

```
Webhook → Function (payload format) → Slack → Response
```

### Örnek 2: Database Kaydet + Notification

```
Webhook 
  ↓
Validate Data
  ↓
Database (Create)
  ↓
Email Notification (optional)
  ↓
Response to Bot
```

### Örnek 3: LLM ile İşle

```
Webhook 
  ↓
OpenAI / HuggingFace (prompt)
  ↓
Response Format
  ↓
Bot'a Geri Gönder
```

## Kaynaklar

- [N8N Webhook Dokumentasyonu](https://docs.n8n.io/reference/nodes/n8n-nodes-base.webhook/)
- [N8N HTTP Request](https://docs.n8n.io/reference/nodes/n8n-nodes-base.httpRequest/)
- [N8N Expression](https://docs.n8n.io/code-examples/expressions/)
