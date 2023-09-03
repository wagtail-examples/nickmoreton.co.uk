# My Wagtail CMS

This is the source code for my website, [nickmoreton.co.uk](https://nickmoreton.co.uk). It stated out as an example of how to deploy a Wagtail CMS site to PythonAnywhere but I'm going to use it as a test bed for new features and ideas.

The article for deploying to PythonAnywhere can be found [here](https://www.nickmoreton.co.uk/articles/deploy-wagtail-cms-to-pythonanywhere/) and the source code can be found [here](https://github.com/wagtail-examples/tutorial-deploy-pythonanywhere-paid)

## Developer setup (backend)

### Create a virtual environment

```bash
pipenv install
```

### Activate the virtual environment

```bash
pipenv shell
```

### Build and run the docker container (Mysql)

```bash
docker-compose up --build
```

### Run the initial setup commands

```bash
python manage.py migrate
python manage.py createsuperuser
```

### Run the development server

```bash
python manage.py runserver
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
