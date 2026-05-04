# N8N'den Bot'a Mesaj Gönderme

Bot'a mesaj göndermek için API endpoint'lerini kullanabilirsiniz. N8N workflow'unda HTTP Request node'u ile çağrı yapın.

## 🔌 API Endpoints

### 1. Tek Mesaj Gönder: `/send_message`

**HTTP Method:** POST  
**URL:** `http://localhost:5000/send_message`

#### Request Body (JSON)

```json
{
  "chat_id": 123456789,
  "message": "Merhaba! Bu bir test mesajıdır.",
  "parse_mode": "HTML"
}
```

#### Parametreler

| Parametre | Tip | Zorunlu | Açıklama |
|-----------|-----|---------|----------|
| `chat_id` | Integer | ✅ | Telegram kullanıcı ID'si |
| `message` | String | ✅ | Gönderilecek mesaj metni |
| `parse_mode` | String | ❌ | Mesaj formatı: "HTML", "Markdown", "MarkdownV2" (varsayılan: "HTML") |

#### Başarılı Response (200)

```json
{
  "status": "success",
  "message": "Message sent",
  "chat_id": 123456789
}
```

#### Hata Response (400/500)

```json
{
  "status": "error",
  "error": "Missing required fields: chat_id, message"
}
```

---

### 2. Birden Fazla Mesaj Gönder: `/send_message_batch`

**HTTP Method:** POST  
**URL:** `http://localhost:5000/send_message_batch`

#### Request Body (JSON)

```json
{
  "messages": [
    {
      "chat_id": 123456789,
      "message": "Merhaba User 1!",
      "parse_mode": "HTML"
    },
    {
      "chat_id": 987654321,
      "message": "Merhaba User 2!",
      "parse_mode": "Markdown"
    }
  ]
}
```

#### Response (200)

```json
{
  "status": "success",
  "total": 2,
  "results": [
    {
      "chat_id": 123456789,
      "success": true
    },
    {
      "chat_id": 987654321,
      "success": true
    }
  ]
}
```

---

### 3. Sağlık Kontrolü: `/health`

**HTTP Method:** GET  
**URL:** `http://localhost:5000/health`

#### Response (200)

```json
{
  "status": "ok",
  "bot": "running"
}
```

---

## 📝 N8N Workflow Örnekleri

### Örnek 1: Basit Mesaj Gönderme

N8N'de aşağıdaki adımları izleyin:

1. **Webhook** trigger (mesaj al)
2. **HTTP Request** node ekle
   - Method: `POST`
   - URL: `http://telegram-bot:5000/send_message`
   - Body:
   ```json
   {
     "chat_id": {{ $json.user_id }},
     "message": "İşlem tamamlandı!",
     "parse_mode": "HTML"
   }
   ```

### Örnek 2: Veritabanından Mesaj Gönder

```
Webhook (POST /webhook/telegram)
  ↓
Database Query (users tablosundan oku)
  ↓
HTTP Request
  ├─ POST http://telegram-bot:5000/send_message_batch
  └─ Body: {{ $json.messages }}
```

### Örnek 3: Fonksiyonla Formatlama

N8N'de Function node:

```javascript
// Telegram mesajı formatla
return {
  json: {
    chat_id: $json.user_id,
    message: `📢 <b>Bildirim</b>\n\n${$json.notification_text}`,
    parse_mode: "HTML"
  }
};
```

---

## 🎨 Mesaj Formatlaması

### HTML Format

```json
{
  "chat_id": 123456789,
  "message": "<b>Kalın</b> <i>İtalik</i> <u>Altı çizili</u>\n<code>Kod</code>",
  "parse_mode": "HTML"
}
```

### Markdown Format

```json
{
  "chat_id": 123456789,
  "message": "**Kalın** *İtalik* `Kod`\n[Link](https://example.com)",
  "parse_mode": "Markdown"
}
```

### MarkdownV2 Format

```json
{
  "chat_id": 123456789,
  "message": "*Kalın* _İtalik_ `Kod`",
  "parse_mode": "MarkdownV2"
}
```

---

## 🔐 Güvenlik

### Kullanıcı ID'sini Güvenli Tutun

Mesaj gönderirken bot'a gelen webhook'tan kullanıcı ID'sini kullanabilirsiniz:

```json
{
  "chat_id": {{ $json.user_id }},
  "message": "Otomatik yanıt"
}
```

### Rate Limiting

Çok sayıda mesaj gönderiyor iseniz:
- Batch endpoint'ini kullanın (`/send_message_batch`)
- N8N'de rate limiting ayarlayın
- Telegram'ın API limitlerini göz önüne alın

---

## 🧪 cURL ile Test

### Tek Mesaj

```bash
curl -X POST http://localhost:5000/send_message \
  -H "Content-Type: application/json" \
  -d '{
    "chat_id": 123456789,
    "message": "Test mesajı",
    "parse_mode": "HTML"
  }'
```

### Batch Mesaj

```bash
curl -X POST http://localhost:5000/send_message_batch \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"chat_id": 123, "message": "Mesaj 1"},
      {"chat_id": 456, "message": "Mesaj 2"}
    ]
  }'
```

### Sağlık Kontrolü

```bash
curl http://localhost:5000/health
```

---

## 📊 Docker İçinde Kullanım

Docker container'ı başlattığında API otomatik olarak çalışacaktır:

```bash
docker-compose up -d

# API erişim
# Container dışından: http://localhost:5000/health
# Container içinden: http://telegram-bot:5000/health
```

---

## 🔄 İşlem Akışı

```
N8N Webhook
    ↓
POST /send_message
    ↓
Bot tarafından işleme
    ↓
Telegram API'ye gönder
    ↓
Kullanıcıya mesaj ulaş
    ↓
N8N'ye Response
```

---

## ⚠️ Olası Hatalar

### Hata: "chat_id not found"
```json
{
  "error": "Failed to send message"
}
```
**Çözüm:** Chat ID'nin doğru ve kullanıcının bot'u başlatmış olduğundan emin olun.

### Hata: "Invalid parse_mode"
**Çözüm:** `parse_mode` sadece "HTML", "Markdown" veya "MarkdownV2" olabilir.

### Hata: "Connection refused"
**Çözüm:** 
- Bot çalışıyor mu? (`docker-compose ps`)
- Port doğru mu? (`API_PORT=5000`)
- Firewall engel mi?

---

## 📚 Referanslar

- [Telegram Bot API - sendMessage](https://core.telegram.org/bots/api#sendmessage)
- [N8N HTTP Request](https://docs.n8n.io/reference/nodes/n8n-nodes-base.httpRequest/)
- [N8N Expressions](https://docs.n8n.io/code-examples/expressions/)
