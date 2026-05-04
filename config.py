"""
Telegram Bot Konfigürasyonu
Environment değişkenlerinden parametreleri yükler
"""
import os
from dotenv import load_dotenv

# .env dosyasını yükle
load_dotenv()


class Config:
    """Bot konfigürasyonu"""
    
    # Telegram
    TELEGRAM_BOT_TOKEN = os.getenv('TELEGRAM_BOT_TOKEN', '')
    
    # N8N Webhook
    N8N_WEBHOOK_URL = os.getenv('N8N_WEBHOOK_URL', '')
    
    # API Sunucusu
    API_PORT = int(os.getenv('API_PORT', '5000'))
    
    # Bot ayarları
    DEBUG = os.getenv('DEBUG', 'False').lower() == 'true'
    LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
    
    # Timeout ayarları
    REQUEST_TIMEOUT = int(os.getenv('REQUEST_TIMEOUT', '10'))
    
    @staticmethod
    def validate():
        """Gerekli ortam değişkenlerini kontrol et"""
        required_vars = ['TELEGRAM_BOT_TOKEN', 'N8N_WEBHOOK_URL']
        missing = [var for var in required_vars if not os.getenv(var)]
        
        if missing:
            raise ValueError(f"Eksik ortam değişkenleri: {', '.join(missing)}")
        
        return True


# Config örneği
config = Config()
