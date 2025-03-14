#!make

# Sets the path to the Docker Compose command
# At some point this shouldn't be necessary, but it is for now
# until is database is migrated to postgres from mysql which is currently used
# in the project on python anywhere
include .env

.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Docker Compose commands"
	@echo " build          Build the Docker containers"
	@echo " up             Start the Docker containers"
	@echo " down           Stop and remove the Docker containers"
	@echo " destroy        Stop and remove the Docker containers, networks, and volumes"
	@echo " run            Run the Django development server"
	@echo ""
	@echo "Container commands"
	@echo " migrate        Run Django migrations"
	@echo " superuser      Create a superuser"
	@echo " restoredb      Restore the database from a backup"
	@echo " sh             Execute a command in a running container"
	@echo " restart        Restart the containers"
	@echo ""
	@echo "Miscellaneous"
	@echo " quickstart     Build, start, and run the containers (npm & docker)"
	@echo " requirements   Export requirements.txt (uv)"
	@echo " clean          Clean up generated files and folders (node_modules, static, media, etc.)"
	@echo " frontend       Build the frontend (npm)"
	@echo " start          Build the front end and start local development server (npm)"
	@echo ""

# Build the containers
.PHONY: build
build:
	$(DC) build

# Start the containers
.PHONY: up
up:
	$(DC) up -d

# Stop and remove containers, networks, and volumes
.PHONY: down
down:
	$(DC) down

# Restart the containers
.PHONY: restart
restart:
	$(DC) restart

# Execute a command in a running container
.PHONY: sh
sh:
	$(DC) exec app bash

# Run the Django development server
.PHONY: run
run:
	$(DC) exec app python manage.py runserver 0.0.0.0:8000

# Stop and remove the Docker containers, networks, and volumes
.PHONY: destroy
destroy:
	$(DC) down -v

# Run migrations
.PHONY: migrate
migrate:
	$(DC) exec app python manage.py migrate

# Create a superuser
.PHONY: superuser
superuser:
	$(DC) exec app python manage.py createsuperuser

# Collect static files
.PHONY: collectstatic
collectstatic:
	$(DC) exec app python manage.py collectstatic --noinput

# Run tests, you will need to have run `make collectstatic` first
.PHONY: test
test:
	$(DC) exec app python manage.py test

# Quickstart
.PHONY: quickstart
quickstart: frontend build up migrate collectstatic test run

# Build the fontend
.PHONY: frontend
frontend:
	npm install
	npm run build

# Start the frontend and run the local development server
.PHONY: start
start:
	npm install
	npm run build
	npm run start

# Export requirements.txt
.PHONY: requirements
requirements:
	uv export --no-hashes --no-dev --output-file requirements.txt --locked

# Clean up
# rm -rf ./webapp/static_compiled; \ add when needed
.PHONY: clean
clean:
	@echo "WARNING:"
	@echo "This will destroy all data in the database and remove all generated files and folders (node_modules, static, media)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		make destroy; \
		rm -rf ./node_modules ./static ./media db.sqlite3; \
		echo "Cleaned up"; \
	else \
		echo "Aborted"; \
	fi

# TEMPORARY COMMANDS
.PHONY: dumpdata
dumpdata:
	$(DC) exec app python manage.py dumpdata --indent 2 --natural-foreign \
	-e contenttypes \
	-e wagtailimages.rendition \
	-e wagtailsearch > dumps/data.json

.PHONY: restoredb
restoredb:
	$(DC) exec app python manage.py loaddata dumps/data.json

.PHONY: copyimages
copyimages:
	mkdir -p media/original_images
	cp -R mediabackups/original_images/* media/original_images