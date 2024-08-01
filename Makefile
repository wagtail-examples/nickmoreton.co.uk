# Local backend development environment
# PORT 8000

build:
	docker-compose build

up:
	docker-compose up -d

migrate:
	docker-compose exec web python manage.py migrate

run:
	docker-compose exec web python manage.py runserver 0.0.0.0:8000

# frontend development
# PORT 3000

serve:
	npm run server

sh:
	docker-compose exec web bash

# Miscelaneous commands

superuser:
	@docker-compose exec web python manage.py shell --command \
	"from django.contrib.auth import get_user_model; \
	get_user_model().objects.create_superuser('test', 'test@admin.com', 'test')"
	@echo superuser created UN: test PW: test EM: test@admin.com

destroy:
	docker-compose down -v

restoredb:
	docker-compose exec db bash -c 'mysql -u webapp -pwebapp -h localhost webapp < dbbackups/nickmoreton-db-backup.sql'
