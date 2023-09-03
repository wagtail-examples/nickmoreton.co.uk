up:
	pipenv run python manage.py runserver

db:
	docker-compose up -d

start:
	npm start

migrate:
	pipenv run python manage.py migrate
