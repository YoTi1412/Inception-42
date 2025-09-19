NAME	= inception
DC		= docker-compose -f srcs/docker-compose.yml

all: up

build:
	@echo "🔨 Building Docker images..."
	@$(DC) build

up:
	@echo "🚀 Setting up and starting containers..."
	@./setup.sh
	@$(DC) up -d

down:
	@echo "🛑 Stopping containers..."
	@$(DC) down

restart:
	@echo "🔄 Restarting containers..."
	@$(DC) restart

fclean:
	@echo "🔥 Removing containers and images (preserving data)..."
	@$(DC) down --rmi all
	@docker image prune -f
	@docker network prune -f
	@docker volume prune -f

nuke:
	@echo "💥 Removing everything, including data..."
	@./setup.sh --nuke
	@$(DC) down --rmi all
	@docker image prune -f
	@docker network prune -f
	@docker volume prune -f

re: fclean build up
	@echo "✅ Project rebuilt successfully."

.PHONY: all build up down restart fclean nuke re
