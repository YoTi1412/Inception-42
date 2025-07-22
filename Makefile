NAME=inception

DC=docker-compose

all: up

build:
	@echo "🔨 Building Docker images..."
	@$(DC) build --no-cache

up:
	@echo "🚀 Starting containers..."
	@$(DC) up -d

down:
	@echo "🛑 Stopping containers..."
	@$(DC) down

fclean:
	@echo "🔥 Removing containers, volumes, images..."
	@docker-compose down -v --rmi all
	@docker volume prune -f
	@docker image prune -af
	@docker network prune -f
	@sudo rm -rf /home/yoti/data/mysql/*
	@sudo rm -rf /home/yoti/data/wordpress/*

re: fclean build up
	@echo "✅ Project rebuilt successfully."

.PHONY: all build up down fclean re
