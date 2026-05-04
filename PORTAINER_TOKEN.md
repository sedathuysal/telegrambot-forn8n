# Portainer'dan API Token Alma

Portainer'a script aracılığıyla erişim için API token'ı gereklidir.

## 🔑 API Token Oluşturma

### Web UI ile (Manuel)

1. **Portainer'a giriş yap**
   - URL: `http://localhost:9000`
   - Username: `admin`
   - Password: Kendi şifren

2. **Admin Panel'e git**
   - Sol menüden **Settings** → **Users**

3. **API token oluştur**
   - Kendi kullanıcını seç
   - **Tokens** bölümünde **Generate token** butonuna tıkla
   - Token adı gir (örn: `telegram-bot-deploy`)
   - **Generate** butonuna tıkla

4. **Token'ı kopyala**
   - Çıkan token'ı kopyala ve güvenli yerden sakla
   - ⚠️ Token bir daha gösterilmez!

### cURL ile (Programmatik)

İlk defa:
```bash
# Admin credentials ile authentication
ADMIN_USER="admin"
ADMIN_PASS="your-password"

TOKEN=$(curl -s -X POST http://localhost:9000/api/auth \
  -H "Content-Type: application/json" \
  -d "{\"Username\":\"$ADMIN_USER\",\"Password\":\"$ADMIN_PASS\"}" | \
  grep -o '"jwt":"[^"]*' | sed 's/"jwt":"//')

echo "Token: $TOKEN"
```

---

## 🔐 Token Kullanımı

### Environment Variable ile

#### Linux/Mac
```bash
export PORTAINER_TOKEN="your-token-here"
export PORTAINER_URL="http://localhost:9000"

bash portainer-deploy.sh
```

#### Windows PowerShell
```powershell
$env:PORTAINER_TOKEN = "your-token-here"
$env:PORTAINER_URL = "http://localhost:9000"

powershell -ExecutionPolicy Bypass -File portainer-deploy.ps1
```

### Script Parametresi ile

#### Linux/Mac
```bash
bash portainer-deploy.sh \
  --token "your-token-here" \
  --url "http://localhost:9000"
```

#### Windows PowerShell
```powershell
powershell -ExecutionPolicy Bypass -File portainer-deploy.ps1 `
  -PortainerToken "your-token-here" `
  -PortainerUrl "http://localhost:9000"
```

### .env Dosyasında

```bash
# portainer.env
PORTAINER_URL=http://localhost:9000
PORTAINER_TOKEN=your-token-here
```

Sonra:
```bash
source portainer.env
bash portainer-deploy.sh
```

---

## 🧪 Token Testi

### cURL ile

```bash
TOKEN="your-token-here"
URL="http://localhost:9000"

# API testi
curl -X GET "$URL/api/stacks" \
  -H "Authorization: Bearer $TOKEN"

# Response: Stack listesi
```

### Bash Script ile

```bash
#!/bin/bash

TOKEN=${PORTAINER_TOKEN}
URL=${PORTAINER_URL:-http://localhost:9000}

if [ -z "$TOKEN" ]; then
    echo "❌ PORTAINER_TOKEN tanımlanmadı"
    exit 1
fi

echo "🔍 Portainer'a bağlanıyor..."
RESPONSE=$(curl -s -X GET "$URL/api/endpoints" \
  -H "Authorization: Bearer $TOKEN")

echo "$RESPONSE" | grep -q "Name" && echo "✅ Token geçerli" || echo "❌ Token geçersiz"
```

---

## 🔄 Token Yenileme

### Token Silme (Yeni Oluşturmak için)

1. **Web UI:**
   - Portainer → Settings → Users → Tokens
   - İstenmeyen token'ın yanındaki **X** butonuna tıkla

2. **cURL:**
```bash
curl -X DELETE "$PORTAINER_URL/api/users/admin/tokens/token-id" \
  -H "Authorization: Bearer $EXISTING_TOKEN"
```

### Yeni Token Oluştur

Yukarıdaki "API Token Oluşturma" bölümüne bakınız.

---

## ⚠️ Güvenlik Best Practices

### 1. Token Gizliliği

❌ **YAPMA:**
- Token'ı script içine hard-code etme
- Token'ı version control'e commit etme
- Token'ı logs'ta gösterme

✅ **YAP:**
- Environment variable kullan
- `.env` dosyasını `.gitignore`'a ekle
- Sensitive logs maskele

### 2. Token Rotasyonu

```bash
# Her 3 ayda bir yeni token oluştur
# Eski token'ı sil
# Yeni token'ı deployment sistemine güncelle
```

### 3. Token Izinleri

Portainer'da granular permissions ayarla:
- User permissions
- Team permissions
- Resource-based access

### 4. Token Expiration

```bash
# Token validity check
curl -s -X GET "$URL/api/me" \
  -H "Authorization: Bearer $TOKEN" | grep -q "ID" && echo "Valid" || echo "Expired"
```

---

## 🛠️ Sorun Giderme

### "Unauthorized" Hatası

```bash
# Token'ı kontrol et
echo $PORTAINER_TOKEN

# Token geçersiz mi?
curl -s -X GET "$PORTAINER_URL/api/me" \
  -H "Authorization: Bearer $PORTAINER_TOKEN"
```

### Token Expired

- Token'ı yeniden oluştur
- `PORTAINER_TOKEN` environment variable'ı güncelle

### CORS Hatası

```bash
# Portainer'da CORS settings kontrol et
curl -X OPTIONS "$PORTAINER_URL/api/" \
  -H "Origin: http://localhost:3000"
```

### Connection Refused

```bash
# Portainer çalışıyor mu?
docker ps | grep portainer

# Port açık mı?
netstat -an | grep 9000
```

---

## 📚 Referanslar

- [Portainer API Dokumentasyonu](https://app.swaggerhub.com/apis/portainer/portainer-io/2.0)
- [Portainer Authentication](https://docs.portainer.io/api/api-overview)
- [JWT Tokens](https://jwt.io/)

---

## 🔑 Token Yönetim Checklist

- [ ] Token oluşturdun
- [ ] Token'ı güvenli yerde sakla
- [ ] Environment variable'da ayarladın
- [ ] `.env.example`'da dummy value göster
- [ ] `.env` dosyasını `.gitignore`'a ekle
- [ ] Token'ı test ettim
- [ ] Deploy script'i çalıştırdım
- [ ] Production token'ını separate tutuyorum
- [ ] Token rotation planı oluşturdm
