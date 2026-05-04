# Portainer Kurulumu ve Telegram Bot Deploy

Portainer, Docker container'larını web arayüzü ile yönetmenin en kolay yoludur.

## 🚀 Adım 1: Portainer Kurulumu

### Linux / Mac

```bash
docker run -d -p 8000:8000 -p 9000:9000 \
  --name=portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
```

### Windows (PowerShell)

```powershell
docker run -d -p 8000:8000 -p 9000:9000 `
  --name portainer `
  --restart always `
  -v \\.\pipe\docker_engine:\\.\pipe\docker_engine `
  -v portainer_data:C:\data `
  portainer/portainer-ce:latest
```

### Docker Compose ile

```yaml
version: '3.8'

services:
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: always
    ports:
      - "8000:8000"
      - "9000:9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    environment:
      - ADMIN_PASSWORD_FILE=/run/secrets/portainer_password

volumes:
  portainer_data:
```

Başlat:
```bash
docker-compose -f portainer-compose.yml up -d
```

---

## 📋 Adım 2: Portainer'a Erişim

1. Browser'ı aç: **http://localhost:9000**
2. Admin hesabı oluştur:
   - Username: `admin`
   - Password: Güçlü bir şifre gir
3. Docker endpoint'i seç: **Local** seç

---

## 🤖 Adım 3: Telegram Bot Deploy Etme

### Yöntem A: Manual Olarak (En Basit)

1. Portainer'da **Stacks** → **+ Add Stack** tıkla
2. Stack adı: `telegram-bot`
3. Web editor'da [docker-compose.yml](docker-compose.yml) içeriğini yapıştır
4. **Environment variables** bölümünde ekle:
   ```
   TELEGRAM_BOT_TOKEN=your_token_here
   N8N_WEBHOOK_URL=your_webhook_url_here
   API_PORT=5000
   ```
5. **Deploy the stack** butonuna tıkla

### Yöntem B: GitHub Repo'sundan

1. **Stacks** → **+ Add Stack**
2. **Repository** tab'ını seç
3. Repository URL: `https://github.com/your-repo/telegrambot.git`
4. Compose file path: `docker-compose.yml`
5. Environment variables ekle
6. **Deploy**

### Yöntem C: Script ile (Linux/Mac)

```bash
# Token al (Portainer Admin → Users → Generate API token)
export PORTAINER_URL=http://localhost:9000
export PORTAINER_TOKEN=your-api-token

# Deploy script'i çalıştır
bash portainer-deploy.sh
```

### Yöntem D: Script ile (Windows PowerShell)

```powershell
# Token al ve ortam değişkenine ata
$env:PORTAINER_TOKEN = "your-api-token"

# Deploy script'i çalıştır
powershell -ExecutionPolicy Bypass -File portainer-deploy.ps1
```

---

## ✅ Adım 4: Deploy Doğrulama

### Containers Kontrol

1. **Containers** menüsünde `telegram-bot` ara
2. Status: `Running` olmalı
3. **Logs** tab'ına tıkla ve log mesajlarını gör

### API Testi

```bash
# Health check
curl http://localhost:5000/health

# Response:
# {"status": "ok", "bot": "running"}
```

### Telegram'da Bot'u Test Et

1. Telegram bot'unuza mesaj gönder
2. Logları Portainer'da gör:
   ```
   INFO - Webhook başarılı: 123456789 - Merhaba!
   ```

---

## 🛠️ Portainer'da Yönetim

### Container Restart Etme

```
Containers → telegram-bot → Restart
```

### Environment Variables Güncelleme

```
Containers → telegram-bot → Edit (atau Recreate)
```

### Logları İzleme

```
Containers → telegram-bot → Logs → (Auto-refresh ON)
```

### Resource Kullanımı

```
Containers → telegram-bot → Stats
```

---

## 📊 Stack Yönetimi

### Stack Durumu Görüntüle

```
Stacks → telegram-bot → View in compose
```

### Stack Restart

```
Stacks → telegram-bot → Restart
```

### Stack Sil

```
Stacks → telegram-bot → Delete
```

---

## 🔐 Güvenlik

### 1. Admin Şifresi Değiştir

```
Portainer → Settings → Admin user
```

### 2. API Token Oluştur (Scripting için)

```
Portainer → Admin → Users → Manage access tokens
```

### 3. Firewall Kuralları

```bash
# Port 9000 sadece localhost'tan accessible
iptables -A INPUT -p tcp --dport 9000 -s 127.0.0.1 -j ACCEPT
iptables -A INPUT -p tcp --dport 9000 -j REJECT
```

### 4. HTTPS Etkinleştir

```
Portainer → Settings → SSL
```

---

## 🚨 Sorun Giderme

### Portainer Container Başlamıyor

```bash
# Kontrol
docker logs portainer

# Docker socket izinleri (Linux)
sudo chmod 666 /var/run/docker.sock
```

### Bot Container Başlamıyor

1. Stack logs kontrol et
2. Environment variables kontrol et
3. Container inspect et:
   ```
   Containers → telegram-bot → Inspect
   ```

### API Port Erişilemiyor

```bash
# Port açık mı?
docker ps | grep telegram-bot

# Port dinleniyor mu?
netstat -an | grep 5000

# Firewall kontrol
sudo iptables -L
```

---

## 📈 Advanced Konfigürasyon

### Multiple Bots Deploy

```yaml
services:
  telegram-bot-1:
    image: telegram-bot:latest
    environment:
      - TELEGRAM_BOT_TOKEN=${BOT_TOKEN_1}
      - API_PORT=5001
    ports:
      - "5001:5001"

  telegram-bot-2:
    image: telegram-bot:latest
    environment:
      - TELEGRAM_BOT_TOKEN=${BOT_TOKEN_2}
      - API_PORT=5002
    ports:
      - "5002:5002"
```

### Load Balancer ile

```yaml
services:
  nginx:
    image: nginx:latest
    ports:
      - "5000:5000"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro

  telegram-bot-1:
    image: telegram-bot:latest
    environment:
      - API_PORT=5001
    expose:
      - "5001"

  telegram-bot-2:
    image: telegram-bot:latest
    environment:
      - API_PORT=5001
    expose:
      - "5001"
```

---

## 📚 Kaynaklar

- [Portainer Kurulum Rehberi](https://docs.portainer.io/start/install)
- [Portainer Stack Management](https://docs.portainer.io/user/docker/stacks)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)

---

## ⚡ Hızlı Komutlar

```bash
# Portainer curl request örneği
curl -X POST http://localhost:9000/api/stacks \
  -H "Authorization: Bearer $PORTAINER_TOKEN" \
  -H "Content-Type: application/json" \
  -d @stack-payload.json

# Bot stats
docker stats telegram-bot

# Bot logları gerçek zamanlı
docker logs -f telegram-bot
```
