# My Wagtail CMS

This is the source code for my website, [nickmoreton.co.uk](https://www.nickmoreton.co.uk).

## Developer setup (backend)

Copy the `.env.example` file to `.env` and un-comment one of the docker-compose commands for the database you want to use.

```bash
cp .env.example .env
```

### Running the development environment

Run `make` to see all the available commands.

The development environment uses docker-compose to run the mysql database. The makefile has commands to build the docker image, run the database, run the migrations and run the server. Run `make` to see all the available commands.

#### Quick start

```bash
make quickstart
```

#### Full setup

First build and run should include the following commands:

```
make build
make up
make migrate
make runserver
```

View the site at <http://localhost:8000>


## Pull database from production server

```bash
fab pull-db
```
### or you can pull it from the s3 bucket

```bash
fab pull-db-s3
```

#### The makefile has a command to load the database from a file

```bash
make restoredb
```

## Pull media files from production server

```bash
fab pull-media
```

### or you can pull it from the s3 bucket

```bash
fab pull-media-s3
```

## Developer setup (frontend)

### Install the dependencies

```bash
nvm use
npm install
```

### Build & watch the frontend

The django app should be running in the background. The frontend will be served on <http://localhost:3000>

```bash
npm start
```

## Deploy to PythonAnywhere

See the article [here](https://staging.nickmoreton.co.uk/articles/deploy-wagtail-cms-to-pythonanywhere/starting-a-deployment/)

## Development utils

See the article [here](https://github.com/wagtail-examples/tutorial-deploy-pythonanywhere-paid/blob/main/docs/more/e-database-backup-and-restore.md) for DB and [here](https://github.com/wagtail-examples/tutorial-deploy-pythonanywhere-paid/blob/main/docs/more/f-media-files-backup-and-restore.md) for Media files
