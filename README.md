# A Wagtail CMS

This is the source code for my website, [www.nickmoreton.co.uk](https://www.nickmoreton.co.uk)

## Setup for development

Copy the `.env.example` file to `.env`.

```bash
cp .env.example .env
```

Update the `.env` file with the correct value for your Heroku app name.

```bash
 HEROKU_APP_NAME=add-the-app-name
 ```

### Running the development environment (quick start)

```bash
make quickstart
```

- The quickstart will perform and initial build of the frontend assets.
- You will be prompted for the admin username and password.

```bash
make run
```

View the site at <http://localhost:8000>

### Running the development environment (step by step)

Copy the `.env.example` file to `.env`.

```bash
cp .env.example .env
```

Update the `.env` file with the correct value for your Heroku app name.

```bash
 HEROKU_APP_NAME=add-the-app-name
 ```

First build and run should include the following commands:

```
make build
make up
make migrate
make runserver
```

View the site at <http://localhost:8000> (frontend files may be missing, see below)

Create a superuser

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

### Build the frontend

```bash
npm run build
```

### Build & watch the frontend

The wagtail app should be running in the background. The frontend will be served on <http://localhost:3000>

```bash
npm start
```

## Import data and media (from production)

The Heroku env vars are required to be set in the `.env` file for any make commands here.

```bash
make extract-vars
```

### Import the database

```bash
make pull-data
```

### Import the media

```bash
make pull-media
```