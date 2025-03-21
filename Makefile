#!make

include .env # this will make the .env file variables available to the Makefile

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
	@echo "restart        Restart the containers"
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
	@echo "Pulling data from Heroku and S3"
	@echo "============================================================================"
	@echo "The commands below require the Heroku CLI and s3cmd to be installed"
	@echo "you can run the 'extract-vars' target to copy the Heroku config vars to .env"
	@echo "----------------------------------------------------------------------------"
	@echo "extract-vars           Copy Heroku config vars to .env"
	@echo "               update the HEROKU_APP_NAME in the .env file before running"
	@echo "pull-data       Pull the data from the Heroku database and import it into the local database"
	@echo "pull-media      Pull the media from the S3 bucket"

# Build the containers
.PHONY: build
build:
	@$(DC) build

# Start the containers
.PHONY: up
up:
	@$(DC) up -d

# Stop and remove containers, networks, and volumes
.PHONY: down
down:
	@$(DC) down

# Restart the containers
.PHONY: restart
restart:
	@$(DC) restart

# Execute a command in a running container
.PHONY: sh
sh:
	@$(DC) exec app bash

# Run the Django development server
.PHONY: run
run:
	@$(DC) exec $(DC_APP) $(MANAGE) runserver 0.0.0.0:8000

# Stop and remove the Docker containers, networks, and volumes
.PHONY: destroy
destroy:
	@$(DC) down -v

# Run migrations
.PHONY: migrate
migrate:
	@$(DC) exec $(DC_APP) $(MANAGE) migrate

# Create a superuser
.PHONY: superuser
superuser:
	@$(DC) exec $(DC_APP) $(MANAGE) createsuperuser

# Collect static files
.PHONY: collectstatic
collectstatic:
	@$(DC) exec $(DC_APP) $(MANAGE) collectstatic --noinput

# Run tests, you will need to have run `make collectstatic` first
.PHONY: test
test:
	@$(DC) exec $(DC_APP) $(MANAGE) test

# Quickstart blank project
.PHONY: quickstart
quickstart: frontend build up migrate collectstatic superuser

# Build the fontend
.PHONY: frontend
frontend:
	@npm install
	@npm run build

# Start the frontend and run the local development server
.PHONY: start
start:
	@npm install
	@npm run build
	@npm run start

# Export requirements.txt
.PHONY: requirements
requirements:
	@uv export --no-hashes --no-dev --output-file requirements.txt --locked

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
.PHONY: pull-data
pull-data:
	@mkdir -p dbbackups
	@heroku pg:backups:download -a $(HEROKU_APP_NAME)
	@mv latest.dump dbbackups/latest.dump
	@$(DC) exec db sh -c 'psql -U postgres -d postgres -c "DROP DATABASE IF EXISTS webapp;"'
	@$(DC) exec db sh -c 'psql -U postgres -d postgres -c "CREATE DATABASE webapp;"'
	-@$(DC) exec db sh -c 'pg_restore -U postgres -d webapp /backups/latest.dump || true'
	@rm -rf dbbackups/latest.dump

# Pull the media from the S3 bucket
# Not sure why but if you have .s3cfg in your home directory it will use that for the s3cmd command keys etc.
# So you need to remove it at the moment
.PHONY: pull-media
pull-media:
	@echo "Pulling media from S3 bucket"
	@mkdir -p media/original_images
	@$(eval S3CFG=$(PWD)/.s3cfg)
	@s3cmd --config=$(PWD)/.s3cfg --access_key=$(AWS_ACCESS_KEY_ID) --secret_key=$(AWS_SECRET_ACCESS_KEY) sync s3://$(AWS_STORAGE_BUCKET_NAME)/original_images media
	@$(DC) exec $(DC_APP) $(MANAGE) shell -c "from wagtail.images.models import Rendition; Rendition.objects.all().delete()"
	@echo "Media pulled from S3 bucket"


# Copy heroku config vars to .env
# required to run the pull-data and pull-media targets
# update the HEROKU_APP_NAME in the .env file before running
.PHONY: extract-vars
extract-vars:
	$(call heroku_to_env,$(HEROKU_APP_NAME))

# Function to copy Heroku config vars to .env
define heroku_to_env
    $(eval HEROKU_VARS=$(shell heroku config -a $(1) -s))
    $(eval APP_NAME=$(1))
    @> .env
    @echo "HEROKU_APP_NAME=$(APP_NAME)" >> .env
    @for var in $(HEROKU_VARS); do \
        echo "$$var" >> .env; \
    done
    @echo "Heroku config vars copied to .env for app: $(APP_NAME)"
endef

# # Function to get a value from .env file
# define get_env_var
#     $(shell grep "^$(1)=" .env | cut -d '=' -f 2)
# endef

# # Function to create the .s3fg file
# define create_s3cfg
# 	@touch .s3cfg
# 	@echo "[default]" >> .s3cfg
# 	@echo "access_key = $(1)" >> .s3cfg
# 	@echo "secret_key = $(2)" >> .s3cfg
# endef