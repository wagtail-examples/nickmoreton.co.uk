#!/bin/bash

result=$(docker-compose run web python manage.py makemigrations --check --dry-run)

if [ "$result" == "No changes detected" ]; then
    echo "Migrations are up to date."
    exit 0
else
    echo "Migrations are out of date. Please run 'docker-compose run web python manage.py makemigrations' and commit the changes."
    exit 1
fi
