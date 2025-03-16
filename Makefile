#!make

include .env

DC=docker compose -f docker-compose.yaml
DC_APP=app
MANAGE=python manage.py

.PHONY: help
help:
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Docker Compose targets"
	@echo "======================="
	@echo "build          Build the Docker containers"
	@echo "down           Stop and remove the Docker containers"
	@echo "destroy        Stop and remove the Docker containers, networks, and volumes"
	@echo "run            Run the Django development server"
	@echo "up             Start the Docker containers"
	@echo ""
	@echo "Container targets"
	@echo "================="
	@echo "collectstatic  Collect static files"
	@echo "migrate        Run Django migrations"
	@echo "pulldata       Run pg_restore -U postgres -d postgres latest.dump in the db container"
	@echo "pullmedia      Pull the media from the S3 bucket"
	@echo "restart        Restart the containers"
	@echo "restoredb      Restore the database from a backup"
	@echo "sh             Execute a command in a running container"
	@echo "superuser      Create a superuser"
	@echo "test           Run tests"
	@echo ""
	@echo "Miscellaneous targets"
	@echo "====================="
	@echo "clean          Clean up generated files and folders (node_modules, static, media, etc.)"
	@echo "frontend       Build the frontend (npm)"
	@echo "quickstart     Build and start all (npm & docker)"
	@echo "requirements   Export requirements.txt (uv)"
	@echo "start          Build the front end and start local development server (npm)"
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
	$(DC) exec $(DC_APP) $(MANAGE) runserver 0.0.0.0:8000

# Stop and remove the Docker containers, networks, and volumes
.PHONY: destroy
destroy:
	$(DC) down -v

# Run migrations
.PHONY: migrate
migrate:
	$(DC) exec $(DC_APP) $(MANAGE) migrate

# Create a superuser
.PHONY: superuser
superuser:
	$(DC) exec $(DC_APP) $(MANAGE) createsuperuser

# Collect static files
.PHONY: collectstatic
collectstatic:
	$(DC) exec $(DC_APP) $(MANAGE) collectstatic --noinput

# Run tests, you will need to have run `make collectstatic` first
.PHONY: test
test:
	$(DC) exec $(DC_APP) $(MANAGE) test

# Quickstart blank project
.PHONY: quickstart
quickstart: frontend build up migrate collectstatic superuser

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
		rm -rf ./node_modules ./static ./media ./dbbackups db.sqlite3; \
		echo "Cleaned up"; \
	else \
		echo "Aborted"; \
	fi

# Pull the data using the Heroku CLI and import it into the local database
.PHONY: pulldata
pulldata:
	mkdir -p dbbackups
	heroku pg:backups:download -a $(HEROKU_APP_NAME)
	mv latest.dump dbbackups/latest.dump
	$(DC) exec db sh -c 'psql -U postgres -d postgres -c "DROP DATABASE IF EXISTS webapp;"'
	$(DC) exec db sh -c 'psql -U postgres -d postgres -c "CREATE DATABASE webapp;"'
	$(DC) exec db sh -c 'pg_restore -U postgres -d webapp /backups/latest.dump'

# Pull the media from the S3 bucket
.PHONY: pullmedia
pullmedia:
	mkdir -p media/original_images
	$(eval AWS_ACCESS_KEY_ID=$(shell heroku config:get AWS_ACCESS_KEY_ID -a $(HEROKU_APP_NAME)))
	$(eval AWS_SECRET_ACCESS_KEY=$(shell heroku config:get AWS_SECRET_ACCESS_KEY -a $(HEROKU_APP_NAME)))
	$(eval AWS_STORAGE_BUCKET_NAME=$(shell heroku config:get AWS_STORAGE_BUCKET_NAME -a $(HEROKU_APP_NAME)))
	s3cmd --access_key=$(AWS_ACCESS_KEY_ID) --secret_key=$(AWS_SECRET_ACCESS_KEY) sync s3://$(AWS_STORAGE_BUCKET_NAME)/original_images media
	$(DC) exec $(DC_APP) $(MANAGE) shell -c "from wagtail.images.models import Rendition; Rendition.objects.all().delete()"
