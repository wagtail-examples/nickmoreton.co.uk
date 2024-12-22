# Makefile for Docker Compose commands

# Variables
DOCKER_COMPOSE_FILE = docker-compose.yml
DC = docker compose -f $(DOCKER_COMPOSE_FILE)

# Default target
.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo " Docker Compose commands"
	@echo "  build      Build the Docker containers"
	@echo "  up         Start the Docker containers"
	@echo "  down       Stop and remove the Docker containers"
	@echo "  destroy    Stop and remove the Docker containers, networks, and volumes"
	@echo "  runserver  Run the Django development server"
	@echo "  serve      Serve via npm"
	@echo ""
	@echo " Container commands"
	@echo "  migrate    Run Django migrations"
	@echo "  superuser  Create a superuser"
	@echo "  restoredb  Restore the database from a backup"
	@echo "  exec       Execute a command in a running container"
	@echo "  logs       Show logs for the containers"
	@echo "  restart    Restart the containers"
	@echo ""
	@echo " Other commands"
	@echo "  exportp   Export the production requirements"
	@echo "  exportd   Export the development requirements"
	@echo "  exporta   Export all requirements"

# Build the containers
.PHONY: build
build:
	$(DC) build --progress=plain

# Start the containers, check for .env file
.PHONY: up
up:
	@if [ ! -f .env ]; then \
		echo "Error: .env file not found"; \
		echo "Run 'cp .env.example .env'"; \
		exit 1; \
	fi
	$(DC) up -d

# Stop and remove containers, networks, and volumes
.PHONY: down
down:
	$(DC) down

# Show logs for containers
.PHONY: logs
logs:
	$(DC) logs

# Restart the containers
.PHONY: restart
restart:
	$(DC) restart

# Execute a command in a running container
.PHONY: exec
exec:
	@read -p "Enter command to run: " cmd; \
	$(DC) exec web $$cmd

# Run the Django development server
.PHONY: runserver
runserver:
	$(DC) exec web python manage.py runserver 0.0.0.0:8000

# Stop and remove the Docker containers, networks, and volumes
.PHONY: destroy
destroy:
	$(DC) down -v

# Run migrations
.PHONY: migrate
migrate:
	$(DC) exec web python manage.py migrate

# Create a superuser
.PHONY: superuser
superuser:
	$(DC) exec web python manage.py createsuperuser

# Restore the database from a backup
.PHONY: restoredb
restoredb:
	$(DC) exec db bash -c 'mysql -u webapp -pwebapp -h localhost webapp < dbbackups/nickmoreton-db-backup.sql'

# Serve via npm
.PHONY: serve
serve:
	npm start


# Export requirements with dev dependencies
.PHONY: exportd
exportd:
	uv export -o requirements.dev.txt --no-hashes --only-dev

# Export requirements without dev dependencies
.PHONY: exportp
exportp:
	uv export -o requirements.prod.txt --no-hashes --no-dev


# Export all requirements files
.PHONY: exporta
exporta:
	@make exportd
	@make exportp
