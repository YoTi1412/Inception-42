NAME=inception

DC=docker-compose

all: up

build:
	@echo "🔨 Building Docker images..."
	@$(DC) build # --no-cache

up:
	@echo "🚀 Starting containers..."
	@$(DC) up -d

down:
	@echo "🛑 Stopping containers..."
	@$(DC) down

restart:
	@echo "🔄 Restarting containers..."
	@$(DC) restart

fclean:
	@echo "🔥 Removing containers, volumes, images..."
	@docker-compose down -v --rmi all
	@docker volume prune -f
	@docker image prune -af
	@docker network prune -f

re: fclean build up
	@echo "✅ Project rebuilt successfully."

.PHONY: all build up down restart fclean re