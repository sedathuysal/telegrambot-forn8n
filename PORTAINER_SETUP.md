# Portainer'a Telegram Bot Kurulumu

Portainer ile Telegram bot'u kolayca yükleyebilirsiniz. İki yöntem var:

## Yöntem 1: Docker Compose Stack (Önerilen) ⭐

### Adım 1: Portainer'a Giriş Yap

1. Portainer web arayüzünü aç: `http://localhost:9000`
2. Username ve password ile giriş yap

### Adım 2: Stack Oluştur

1. Sol menüden **Stacks** → **+ Add Stack** tıkla
2. **Stack name** gir: `telegram-bot`

### Adım 3: Docker Compose Kodu Yapıştır

**Web editor**'da aşağıdaki kodu yapıştır:

```yaml
version: '3.8'

services:
  telegram-bot:
    image: telegram-bot:latest
    build:
      context: .
      dockerfile: Dockerfile
    container_name: telegram-bot
    restart: unless-stopped
    environment:
      - TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
      - N8N_WEBHOOK_URL=${N8N_WEBHOOK_URL}
      - API_PORT=${API_PORT:-5000}
      - DEBUG=${DEBUG:-false}
      - LOG_LEVEL=${LOG_LEVEL:-INFO}
      - REQUEST_TIMEOUT=${REQUEST_TIMEOUT:-10}
    ports:
      - "${API_PORT:-5000}:5000"
    networks:
      - telegram-net
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

networks:
  telegram-net:
    driver: bridge
```

### Adım 4: Environment Variables Ekle

**Environment variables** bölümünde şu değişkenleri ekle:

```
TELEGRAM_BOT_TOKEN=your_bot_token_here
N8N_WEBHOOK_URL=https://your-n8n-instance.com/webhook/telegram
API_PORT=5000
DEBUG=false
LOG_LEVEL=INFO
REQUEST_TIMEOUT=10
```

Veya **Load variables from .env file** seçeneğini kullan.

### Adım 5: Deploy Et

1. **Deploy the stack** butonuna tıkla
2. Container başladığını kontrol et (Containers → telegram-bot)
3. Logları görüntüle: **Logs** tab'ına tıkla

---

## Yöntem 2: GitHub'dan Pull Ederek

### Adım 1: Repository Klonla

Portainer'da terminal açıp:

```bash
cd /opt
git clone https://github.com/your-repo/telegrambot.git
cd telegrambot
```

### Adım 2: Stack Deploy Et

```bash
cd /opt/telegrambot
portainer-compose deploy -f docker-compose.yml -n telegram-bot
```

---

## Yöntem 3: Private Registry'den (Enterprise)

Eğer Docker image'ı private registry'de sakla iyorsan:

```yaml
services:
  telegram-bot:
    image: registry.example.com/telegram-bot:latest
    build:
      context: .
      dockerfile: Dockerfile
      args:
        - BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
    # ... rest of config
```

---

## 🔍 Portainer'da Kontrol Etme

### Container Logları
```
Containers → telegram-bot → Logs
```

### Environment Variables Kontrol
```
Containers → telegram-bot → Inspect
```

### API Testi
```
Network → telegram-net → container IP
Port: 5000
```

---

## 📊 Portainer Stack Yönetimi

### Stack Durumu Kontrol
- **Stacks** menüsünde `telegram-bot` stack'ini gör
- Status: `Active` olmalı

### Restart Etme
```
Stacks → telegram-bot → Restart
```

### Log Görüntüleme
```
Stacks → telegram-bot → Logs
```

### Scale Etme (Birden Fazla Instance)
```yaml
services:
  telegram-bot:
    # ... config
    deploy:
      replicas: 2  # 2 adet çalıştır
```

---

## 🚀 Advanced: Portainer Template Oluştur

**Portainer Admin** → **App Templates** → **Custom Templates**

Aşağıdaki JSON template oluştur:

```json
{
  "version": "2",
  "templates": [
    {
      "type": 3,
      "title": "Telegram Bot",
      "name": "telegram-bot",
      "description": "N8N integrated Telegram bot",
      "categories": ["Bot", "Automation"],
      "platform": "linux",
      "logo": "https://telegram.org/img/t_logo.png",
      "repository": {
        "url": "https://github.com/your-repo/telegrambot",
        "stackfile": "docker-compose.yml"
      },
      "env": [
        {
          "name": "TELEGRAM_BOT_TOKEN",
          "label": "Bot Token",
          "description": "Telegram Bot Token from @BotFather",
          "type": "password"
        },
        {
          "name": "N8N_WEBHOOK_URL",
          "label": "N8N Webhook URL",
          "description": "N8N webhook endpoint"
        },
        {
          "name": "API_PORT",
          "label": "API Port",
          "default": "5000"
        }
      ]
    }
  ]
}
```

---

## 🔐 Güvenlik Ayarları

### 1. Secret Variables Kullan

Portainer'da sensitive değerleri environment variables yerine **Secrets** olarak sakla:

```yaml
services:
  telegram-bot:
    secrets:
      - telegram_token
    environment:
      - TELEGRAM_BOT_TOKEN_FILE=/run/secrets/telegram_token

secrets:
  telegram_token:
    external: true
```

### 2. Network Isolation

```yaml
networks:
  telegram-net:
    driver: bridge
    driver_opts:
      com.docker.network.bridge.enable_ip_masquerade: "true"
```

### 3. Resource Limits

```yaml
services:
  telegram-bot:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

---

## 🐛 Sorun Giderme

### Container Başlamıyor

1. **Logs kontrol et:**
   ```
   Containers → telegram-bot → Logs
   ```

2. **Environment variables kontrol:**
   ```
   Containers → telegram-bot → Inspect → Config → Env
   ```

3. **Restart et:**
   ```
   Containers → telegram-bot → Restart
   ```

### API Port Erişilemiyor

- Port open mı? `docker ps` ile kontrol et
- Firewall kuralını kontrol et
- Port 5000'in başka servis tarafından kullanılmadığını kontrol et

### Webhook Bağlantı Hatası

- N8N URL'sini doğru yazmış mı? `docker logs telegram-bot`
- Network bağlantısı aktif mı?
- Credentials doğru mu?

---

## 📈 Monitoring Portainer'da

### Container Stats
```
Containers → telegram-bot → Stats
```

### Resource Usage
- CPU, Memory, Network görüntüle
- Alert'ler ayarla

### Event Log
```
Cluster → Events
```

---

## 🔄 CI/CD Integration

### GitHub Actions ile Portainer Deploy

```yaml
name: Deploy to Portainer

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy Stack
        run: |
          curl -X POST http://portainer-host:9000/api/stacks \
            -H "Authorization: Bearer ${{ secrets.PORTAINER_TOKEN }}" \
            -H "Content-Type: application/json" \
            -d @portainer-stack.json
```

---

## 📚 Kaynaklar

- [Portainer Dokumentasyonu](https://docs.portainer.io/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Portainer Stack Management](https://docs.portainer.io/user/docker/stacks)
