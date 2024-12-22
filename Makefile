# Makefile for Docker Compose commands

# Variables
DOCKER_COMPOSE_FILE = docker-compose.yml
DC = docker compose -f $(DOCKER_COMPOSE_FILE)

# Targets
.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Commands useful for development"
	@echo "====================================================================="
	@echo "Database"
	@echo "========"
	@echo " dbuild:         Build the Docker containers"
	@echo " dup:            Start the Docker containers"
	@echo " ddown:          Stop and remove the Docker containers"
	@echo " ddestroy:       Stop and remove the Docker containers, networks, and volumes"
	@echo " dexecdb:        Execute a command in a running container"
	@echo " drestart:       Restart the containers"
	@echo " drestoredb:     Restore the database from a backup"
	@echo ""
	@echo "UV"
	@echo "=="
	@echo " uvvenv:         Create a virtual environment"
	@echo " uvsync:         Sync the virtual environment"
	@echo " uvexportp:      Export the production requirements"
	@echo " uvexportd:      Export the development requirements"
	@echo " uvexporta:      Export all requirements"
	@echo " uvtreetop:	  	Display the top level dependency tree"
	@echo ""
	@echo "Python"
	@echo "======"
	@echo " migrate:        Run Django migrations"
	@echo " superuser:      Create a superuser"
	@echo " runserver:      Run the Django development server"
	@echo ""
	@echo "Node"
	@echo "===="
	@echo " install:        Install npm packages"
	@echo " start:          Start the development server"
	@echo " serve:          Serve via npm"
	@echo ""
	@echo "Other commands"
	@echo "=============="
	@echo "  cleanup:       Clean up the project directory"
	@echo "====================================================================="

### DOCKER

# Build the containers
.PHONY: dbuild
dbuild:
	$(DC) --progress plain build

# Start the containers, check for .env file
.PHONY: dup
dup:
	@if [ ! -f .env ]; then \
		echo "Error: .env file not found"; \
		echo "Run 'cp .env.example .env'"; \
		exit 1; \
	fi
	$(DC) up -d --remove-orphans

# Stop and remove containers, networks, and volumes
.PHONY: ddown
ddown:
	$(DC) down

# Stop and remove the Docker containers, networks, and volumes
.PHONY: ddestroy
ddestroy:
	$(DC) down -v

# Execute a command in a running container
.PHONY: dexec
dexec:
	@read -p "Enter command to run: " cmd; \
	$(DC) exec db $$cmd

# Restart the containers
.PHONY: drestart
drestart:
	$(DC) restart

# Restore the database from a backup
.PHONY: drestoredb
drestoredb:
	$(DC) exec db bash -c 'mysql -u webapp -pwebapp -h localhost webapp < dbbackups/nickmoreton-db-backup.sql'

### UV

# Create a virtual environment
.PHONY: uvvenv
uvvenv:
	uv venv

# Sync the virtual environment
.PHONY: uvsync
uvsync:
	uv sync

# Export requirements with dev dependencies
.PHONY: uvexportd
uvexportd:
	uv export -o requirements.dev.txt --no-hashes --only-dev

# Export requirements without dev dependencies
.PHONY: uvexportp
uvexportp:
	uv export -o requirements.prod.txt --no-hashes --no-dev

# Export all requirements files
.PHONY: uvexporta
uvexporta:
	@make exportd
	@make exportp

# Display the top level dependency tree
.PHONY: uvtreetop
uvtreetop:
	uv tree --depth=1
	@echo "Run 'uv tree' for the full dependency tree"

### PYTHON

# Run migrations
.PHONY: migrate
migrate:
	uv run python manage.py migrate

# Create a superuser
.PHONY: superuser
superuser:
	uv run python manage.py createsuperuser

# Run the Django development server
.PHONY: runserver
runserver:
	uv run python manage.py runserver

### NODE

# NPM Serve
.PHONY: serve
serve:
	npm install
	npm start

# Clean up the project directory
.PHONY: cleanup
cleanup:
	rm -rf node_modules
	rm -rf dbbackups
	rm -rf db_data
	rm -rf static
