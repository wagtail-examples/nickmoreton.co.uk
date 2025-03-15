# A Wagtail CMS

This is the source code for my website, [www.nickmoreton.co.uk](https://www.nickmoreton.co.uk)

## Developer setup (backend)

Copy the `.env.example` file to `.env` and un-comment one of the docker-compose commands for the database you want to use.

```bash
cp .env.example .env
```

Supports the following databases:

- MySQL
- PostgreSQL
- SQLite

## Running the development environment

Run `make` to see all the available commands.

The development environment uses docker-compose to run the site with a specific database during development.

### Quick start

```bash
make quickstart
```

The quickstart will also perform and initial build of the frontend assets.

## Manual setup

First build and run should include the following commands:

```
make build
make up
make migrate
make runserver
```

View the site at <http://localhost:8000>

## Create a superuser

```bash
make superuser
```

View the admin at <http://localhost:8000/admin>

## Developer setup (frontend)

### Install the dependencies

```bash
nvm use
npm install
```

### Build & watch the frontend

The wagtail app should be running in the background. The frontend will be served on <http://localhost:3000>

```bash
npm start
```

### Build the frontend

```bash
npm run build
```
