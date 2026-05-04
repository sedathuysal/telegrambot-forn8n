"""
Telegram Bot - N8N Webhook İntegrasyonu
Mesaj geldiğinde n8n workflow'a webhook POST isteği gönderir
"""
import logging
import requests
import json
import threading
from datetime import datetime
from flask import Flask, request, jsonify
from telegram import Update, constants
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes

from config import config

# Logging ayarı
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=getattr(logging, config.LOG_LEVEL)
)
logger = logging.getLogger(__name__)

# Global telegram app (webhook receiver için erişim)
telegram_app = None


class TelegramBotHandler:
    """Telegram bot işlemleri"""
    
    def __init__(self):
        self.webhook_url = config.N8N_WEBHOOK_URL
        self.timeout = config.REQUEST_TIMEOUT
    
    async def send_to_webhook(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Mesajı N8N webhook'a gönder"""
        try:
            # Webhook için payload hazırla
            payload = {
                "timestamp": datetime.now().isoformat(),
                "user_id": update.effective_user.id,
                "username": update.effective_user.username or "Anonim",
                "first_name": update.effective_user.first_name,
                "last_name": update.effective_user.last_name,
                "chat_id": update.effective_chat.id,
                "message_type": "text",
                "message": update.message.text,
                "raw_update": {
                    "message_id": update.message.message_id,
                    "chat_id": update.effective_chat.id,
                    "date": update.message.date.isoformat() if update.message.date else None,
                }
            }
            
            # N8N webhook'a POST isteği gönder
            response = requests.post(
                self.webhook_url,
                json=payload,
                timeout=self.timeout,
                headers={"Content-Type": "application/json"}
            )
            
            response.raise_for_status()
            logger.info(f"Webhook başarılı: {update.effective_user.id} - {update.message.text[:50]}")
            
            # Kullanıcıya onay mesajı gönder (opsiyonel)
            await context.bot.send_message(
                chat_id=update.effective_chat.id,
                text="✅ Mesajınız işlendi"
            )
            
        except requests.exceptions.Timeout:
            logger.error("Webhook isteği zaman aşımına uğradı")
            await context.bot.send_message(
                chat_id=update.effective_chat.id,
                text="⏱️ İşlem zaman aşımına uğradı"
            )
        except requests.exceptions.RequestException as e:
            logger.error(f"Webhook hatası: {e}")
            await context.bot.send_message(
                chat_id=update.effective_chat.id,
                text="❌ İşlem sırasında hata oluştu"
            )
        except Exception as e:
            logger.error(f"Beklenmeyen hata: {e}")
            await context.bot.send_message(
                chat_id=update.effective_chat.id,
                text="⚠️ Bir hata oluştu"
            )
    
    async def start(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Bot başlat komutu"""
        welcome_text = (
            "👋 Hoş geldiniz!\n"
            "Bot hazır. Mesaj gönderdiğinizde işlenecek."
        )
        await context.bot.send_message(
            chat_id=update.effective_chat.id,
            text=welcome_text
        )
        logger.info(f"Yeni kullanıcı başlatıldı: {update.effective_user.id}")
    
    async def help_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Yardım komutu"""
        help_text = (
            "📋 Komutlar:\n"
            "/start - Botu başlat\n"
            "/help - Yardım göster\n\n"
            "Herhangi bir mesaj gönderin ve işlenecek."
        )
        await context.bot.send_message(
            chat_id=update.effective_chat.id,
            text=help_text
        )
    
    async def error_handler(self, update: object, context: ContextTypes.DEFAULT_TYPE):
        """Hata yönetimi"""
        logger.error(f"Update {update} sırasında hata: {context.error}")
    
    async def send_message_to_user(self, chat_id: int, message: str, parse_mode: str = "HTML"):
        """N8N'den gelen mesajı kullanıcıya gönder"""
        try:
            if telegram_app is None:
                logger.error("Telegram app erişilemiyor")
                return False
            
            await telegram_app.bot.send_message(
                chat_id=chat_id,
                text=message,
                parse_mode=parse_mode
            )
            logger.info(f"Mesaj gönderildi: {chat_id}")
            return True
        except Exception as e:
            logger.error(f"Mesaj gönderilemedi: {e}")
            return False


def create_flask_app(bot_handler: TelegramBotHandler) -> Flask:
    """Flask API sunucusu oluştur (N8N webhook receiver)"""
    app = Flask(__name__)
    
    @app.route('/health', methods=['GET'])
    def health():
        """Sağlık kontrolü endpoint'i"""
        return jsonify({"status": "ok", "bot": "running"}), 200
    
    @app.route('/send_message', methods=['POST'])
    def send_message():
        """
        N8N'den mesaj almak için endpoint
        
        Beklenen JSON payload:
        {
            "chat_id": 123456789,
            "message": "Mesaj içeriği",
            "parse_mode": "HTML"  # opsiyonel
        }
        """
        try:
            data = request.get_json()
            
            # Gerekli parametreleri kontrol et
            if not data:
                return jsonify({"error": "Empty payload"}), 400
            
            chat_id = data.get('chat_id')
            message = data.get('message')
            parse_mode = data.get('parse_mode', 'HTML')
            
            if not chat_id or not message:
                return jsonify({
                    "error": "Missing required fields: chat_id, message"
                }), 400
            
            # Validasyon
            try:
                chat_id = int(chat_id)
            except (ValueError, TypeError):
                return jsonify({"error": "chat_id must be an integer"}), 400
            
            logger.info(f"N8N'den mesaj alındı: chat_id={chat_id}")
            
            # Mesajı gönder (async olarak)
            import asyncio
            loop = asyncio.new_event_loop()
            success = loop.run_until_complete(
                bot_handler.send_message_to_user(chat_id, message, parse_mode)
            )
            loop.close()
            
            if success:
                return jsonify({
                    "status": "success",
                    "message": "Message sent",
                    "chat_id": chat_id
                }), 200
            else:
                return jsonify({
                    "status": "error",
                    "message": "Failed to send message"
                }), 500
                
        except Exception as e:
            logger.error(f"N8N endpoint hatası: {e}")
            return jsonify({"error": str(e)}), 500
    
    @app.route('/send_message_batch', methods=['POST'])
    def send_message_batch():
        """
        Birden fazla kullanıcıya mesaj gönder
        
        Beklenen JSON payload:
        {
            "messages": [
                {"chat_id": 123, "message": "Mesaj 1"},
                {"chat_id": 456, "message": "Mesaj 2"}
            ]
        }
        """
        try:
            data = request.get_json()
            messages = data.get('messages', [])
            
            if not messages:
                return jsonify({"error": "No messages provided"}), 400
            
            results = []
            import asyncio
            
            for msg_data in messages:
                try:
                    chat_id = int(msg_data.get('chat_id'))
                    message = msg_data.get('message')
                    parse_mode = msg_data.get('parse_mode', 'HTML')
                    
                    if not message:
                        results.append({
                            "chat_id": chat_id,
                            "success": False,
                            "error": "Empty message"
                        })
                        continue
                    
                    loop = asyncio.new_event_loop()
                    success = loop.run_until_complete(
                        bot_handler.send_message_to_user(chat_id, message, parse_mode)
                    )
                    loop.close()
                    
                    results.append({
                        "chat_id": chat_id,
                        "success": success
                    })
                except Exception as e:
                    results.append({
                        "chat_id": msg_data.get('chat_id'),
                        "success": False,
                        "error": str(e)
                    })
            
            return jsonify({
                "status": "success",
                "total": len(messages),
                "results": results
            }), 200
            
        except Exception as e:
            logger.error(f"Batch endpoint hatası: {e}")
            return jsonify({"error": str(e)}), 500
    
    @app.errorhandler(404)
    def not_found(error):
        return jsonify({"error": "Endpoint not found"}), 404
    
    @app.errorhandler(500)
    def internal_error(error):
        return jsonify({"error": "Internal server error"}), 500
    
    return app


def run_flask_server(app: Flask, port: int = 5000):
    """Flask sunucusunu çalıştır (arka planda)"""
    logger.info(f"Flask sunucusu başlatılıyor: http://localhost:{port}")
    app.run(host='0.0.0.0', port=port, debug=False, use_reloader=False)


def main():
    """Bot'u başlat"""
    global telegram_app
    
    # Config kontrol et
    try:
        config.validate()
    except ValueError as e:
        logger.error(f"Konfigürasyon hatası: {e}")
        raise
    
    logger.info("Telegram Bot başlatılıyor...")
    logger.info(f"N8N Webhook: {config.N8N_WEBHOOK_URL}")
    
    # Bot handler oluştur
    handler = TelegramBotHandler()
    
    # Application oluştur
    application = Application.builder().token(config.TELEGRAM_BOT_TOKEN).build()
    telegram_app = application
    
    # Command handlers ekle
    application.add_handler(CommandHandler("start", handler.start))
    application.add_handler(CommandHandler("help", handler.help_command))
    
    # Tüm metin mesajlarını işle
    application.add_handler(
        MessageHandler(filters.TEXT & ~filters.COMMAND, handler.send_to_webhook)
    )
    
    # Hata handler ekle
    application.add_error_handler(handler.error_handler)
    
    # Flask sunucusunu arka planda başlat (threading)
    flask_app = create_flask_app(handler)
    flask_thread = threading.Thread(
        target=run_flask_server,
        args=(flask_app, config.API_PORT),
        daemon=True
    )
    flask_thread.start()
    logger.info(f"API Sunucusu başlatıldı: http://localhost:{config.API_PORT}")
    
    # Bot'u başlat (polling)
    logger.info("Bot çalışıyor...")
    logger.info("Mesaj göndermek için POST isteği: http://localhost:{}/send_message".format(config.API_PORT))
    application.run_polling(allowed_updates=Update.ALL_TYPES)


if __name__ == "__main__":
    main()
