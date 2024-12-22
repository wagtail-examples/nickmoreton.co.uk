#!/bin/bash

# result=$(docker compose run web bash -c "python manage.py makemigrations --check --dry-run")
result=$(uv run python manage.py makemigrations --check --dry-run)
echo $result

if [ "$result" == "No changes detected" ]; then
    echo "Migrations are up to date."
    exit 0
else
    echo "Migrations are out of date."
    exit 1
fi
