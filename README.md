# My Wagtail CMS

This is the source code for my website, [nickmoreton.co.uk](https://nickmoreton.co.uk). It stated out as an example of how to deploy a Wagtail CMS site to PythonAnywhere but I'm going to use it as a test bed for new features and ideas.

The article for deploying to PythonAnywhere can be found [here](https://www.nickmoreton.co.uk/articles/deploy-wagtail-cms-to-pythonanywhere/) and the source code can be found [here](https://github.com/wagtail-examples/tutorial-deploy-pythonanywhere-paid)

## Developer setup (backend)

### Copy the .env.example file to .env

```bash
cp .env.example .env
```

Then update the values for the environment variables in the .env file.

### Running the development environment

The development environment uses docker-compose to run the mysql database. The makefile has commands to build the docker image, run the database, run the migrations and run the server.

```
make build
make up
make migrate
make run
```

### Destroy the development environment

```bash
make destroy
```

### Running commands in the development environment

```bash
make sh
```

### Miscellaneous commands

```bash
make superuser # Create a superuser
make restoredb # Restore the database from a backup in db_data
```

View the site at <http://localhost:8000>

## Pull media and database from production

```bash
fab pull-db
```

```bash
fab pull-media
```

## Developer setup (frontend)

### Install the dependencies

```bash
nvm use
npm install
```

### Build & watch the frontend

```bash
npm start
```

### Build the frontend

```bash
npm run build
```

## Deploy to PythonAnywhere

See the article [here](https://staging.nickmoreton.co.uk/articles/deploy-wagtail-cms-to-pythonanywhere/starting-a-deployment/)

## Development utils

See the article [here](https://github.com/wagtail-examples/tutorial-deploy-pythonanywhere-paid/blob/main/docs/more/e-database-backup-and-restore.md) for DB and [here](https://github.com/wagtail-examples/tutorial-deploy-pythonanywhere-paid/blob/main/docs/more/f-media-files-backup-and-restore.md) for Media files
