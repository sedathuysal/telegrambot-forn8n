.PHONY: help build up down logs restart stop clean

help:
	@echo "=== Telegram Bot Commands ==="
	@echo "make build       - Docker image'ı derle"
	@echo "make up          - Bot'u başlat (arka planda)"
	@echo "make down        - Bot'u durdur"
	@echo "make logs        - Bot loglarını göster"
	@echo "make restart     - Bot'u yeniden başlat"
	@echo "make stop        - Bot'u durdur"
	@echo "make clean       - Container ve image'ı sil"
	@echo "make env         - .env dosyası oluştur"

build:
	docker-compose build

up:
	docker-compose up -d

down:
	docker-compose down

logs:
	docker-compose logs -f telegram-bot

restart:
	docker-compose restart

stop:
	docker-compose stop

clean:
	docker-compose down -v
	docker-compose rmi

env:
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo ".env dosyası oluşturuldu"; \
	else \
		echo ".env dosyası zaten mevcut"; \
	fi

status:
	docker-compose ps

shell:
	docker-compose exec telegram-bot /bin/bash
