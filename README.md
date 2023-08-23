# Wagtail CMS site deployed to PythonAnywhere

This is a tutorial about one way to build and deploy a Wagtail CMS site to [PythonAnywhere](https://www.pythonanywhere.com).

I'm going to build a site for myself, [nickmoreton.co.uk](https://nickmoreton.co.uk). I'm not sure yet what I'm going to put on it, but I'll figure that out as I go along. It's a starting point that has all the elements one might need to build a Wagtail site and deploy it live.

The official [Wagtail documentation](https://wagtail.org) is excellent and I recommend you read the [Developer Documentation](https://docs.wagtail.org/en/stable/), specifically [Your first wagtail site](https://docs.wagtail.org/en/stable/getting_started/tutorial.html) but I wanted to document the process I go through.

I've actually built and deployed a fair few Wagtail sites over the last decade, as a freelancer and I now work for [Torchbox](https://torchbox.com) as a developer.

The tech stack so far is:

- ✅ Python:3.10
- ✅ Mysql:5.7 (this is a limitation of PythonAnywhere)
- ✅ Node / webpack to build the frontend
- ✅ CI actions for code checks
- ✅ Pre-commit to run git hooks
- ✅ Git push deployments to PythonAnywhere (like Heroku etc.)
- ✅ Wagtail CMS v5.1.1
- ✅ Django 4.1 (Mysql 5.7 requires Django < 4.2)

The finished source code for the live site is here [https://github.com/nickmoreton/nickmoreton.co.uk](https://github.com/nickmoreton/nickmoreton.co.uk) on the `main` branch and will become more complete over time. It's a work in progress and at the moment is just a home page.

Because I'm using git push to deploy the webapp and that requires SSH access, I need to use the paid version of PythonAnywhere, which starts at €5/month. You could use a free account but you'll need to do your deployments manually and use `git pull` to update the code.

## Contents

- [Create a git repo to store the source code](./docs/a-1-create-a-origin-repo.md)
- [Set up a webapp on PythonAnywhere](./docs/a-2-create-a-webapp.md)
- [Python dependencies](./docs/b-python-dependencies.md)
- [Start a Wagtail site](./docs/c-wagtail-start.md)
- [Setup environment variables](./docs/d-add-envvars.md)
- [Add a local mysql docker container for development](./docs/e-add-mysql-docker.md)
- [Configure Wagtail to use the Mysql database](./docs/f-switch-to-mysql.md)
- Up and running locally...
- [Create a Mysql database on PythonAnywhere](./docs/g-create-mysql-on-pythonanywhere.md)
- [Update some web app settings on PythonAnywhere](./docs/h-update-some-webapp-settings.md)
- [Alter Wagtail settings to use more environment variables](./docs/i-alter-settings-extra-vars.md)
- [Add further steps to the post-recieve hook](./docs/j-add-further-deploy-hooks.md)
- [Update the WSGI file on PythonAnywhere](./docs/k-update-the-wsgi-file.md)
- [Start a deployemnt](./docs/l-push-to-the-bare-repo.md)
- Up and running on PythonAnywhere...
- [Add code quality checks](./docs/m-add-code-quality-checks.md)
- [Add frontend/webpack to the project](./docs/n-frontend-compiling.md)
- [Use pre-commit to ensure static assets are production ready](./docs/o-static-compiled-pre-commit.md)
- Try out a push to the bare repo...
- [Add CI checks for migrations and requirements](./docs/p-ci-checks-requirements-migrations.md)

Up Next - [Create a git repo to store the source code](./docs/a-1-create-a-origin-repo.md)

## Whats missing?

There's more that could be done.

### A staging/client review site

When building new features, it's useful to have a staging site that the client can review. This isn't complicated to set up on PythonAnywhere because you can have multiple sites on one account, they only cost just over €1/month extra for each one.

You'd need to create a new webapp and a new database. Then go through the steps in this tutorial again and use a different branch for the code e.g. `staging`.

### A backup strategy

It's possible to add a scheduled task in PythonAnywhere to run a script that backs up the database and uploads it to a cloud storage provider like AWS S3. You could also backup the media files in the same way.

See [#database-backup-and-restore](#database-backup-and-restore) for how to prepare database backups. The command could be adjusted to generate a timestamped backup that would be uploaded it to S3 storage.

> I use [Linode Object Storage](https://www.linode.com/products/object-storage/) for backup file storage.

### A guide to using git pull deployments

I've not covered this in this tutorial but it's possible to use git pull deployments on PythonAnywhere. You can still use this tutorial to get up and running but you'll need to do your deployments from a console on PythonAnywhere using `git pull`.

#### Roughly: You'd need to follow these steps

- [Set up a webapp on PythonAnywhere](./docs/a-2-create-a-webapp.md)
- [Python dependencies](./docs/b-python-dependencies.md)
- [Start a Wagtail site](./docs/c-wagtail-start.md)
- [Setup environment variables](./docs/d-add-envvars.md)
- [Add a local mysql docker container for development](./docs/e-add-mysql-docker.md)
- [Configure Wagtail to use the Mysql database](./docs/f-switch-to-mysql.md)
- Up and running locally...
- [Create a Mysql database on PythonAnywhere](./docs/g-create-mysql-on-pythonanywhere.md)
- [Update some web app settings on PythonAnywhere](./docs/h-update-some-webapp-settings.md)
- [Alter Wagtail settings to use more environment variables](./docs/i-alter-settings-extra-vars.md)
- [Update the WSGI file on PythonAnywhere](./docs/k-update-the-wsgi-file.md)
- Git pull your code...

But not set up the bare-repo and post-receive hook.

### How to setup sending emails

Outbound emails are useful for at least password reminders but more so for notifications if using the Wagtail Form Builder. There's lots of 3rd party services that can be used for this. But for small sites SMTP from your email provider should be fine.

It could be as easy as adding the following to the `settings/base.py` file:

```python
# EMAIL
EMAIL_HOST = env_vars["EMAIL_HOST"] if "EMAIL_HOST" in env_vars else ""
EMAIL_PORT = env_vars["EMAIL_PORT"] if "EMAIL_PORT" in env_vars else ""
EMAIL_HOST_USER = env_vars["EMAIL_HOST_USER"] if "EMAIL_HOST_USER" in env_vars else ""
EMAIL_HOST_PASSWORD = env_vars["EMAIL_HOST_PASSWORD"] if "EMAIL_HOST_PASSWORD" in env_vars else ""
EMAIL_SENDER_ADDRESS = env_vars["EMAIL_SENDER_ADDRESS"] if "EMAIL_SENDER_ADDRESS" in env_vars else ""
```

And then adding the environment variables to the `.env` file created here [Setup environment variables](./docs/a-2-create-a-webapp.md#environment-variables-storage)

### Database backup and restore

When developing new features, it's useful to have some real data to work with. You could add data locally but it can take time to create it. It's possible to backup the database and media files from the live site and restore them locally. Also useful is [Media files backup and restore](#media-files-backup-and-restore).

- `*your-account-name*` = your PythonAnywhere account name
- `*your-database-name*` = the name of your database
- replace `mysql.eu.pythonanywhere-services.com` with the mysql server name for your account
- replace `ssh.eu.pythonanywhere.com` with the ssh server name for your account

#### Backup the database

These commands can be used to backup the database on PythonAnywhere.

Open a console on PythonAnywhere and run the following command:

```bash
ssh *your-account-name*@ssh.eu.pythonanywhere.com
```

Create a directory to store the backups:

```bash
mkdir -p ~/dbbackups
```

Then run the following command to backup the database:

> If you're using a PythonAnywhere account where the Mysql version is 5.7 you won't need use `--column-statistics=0` but if you're using Mysql version 8 you will.

```bash
mysqldump -u *your-account-name* -h *your-account-name*.mysql.eu.pythonanywhere-services.com --set-gtid-purged=OFF --no-tablespaces --column-statistics=0 '*your-database-name*' > ~/dbbackups/*your-database-name*.sql
```

Exit the console:

```bash
exit
```

To pull the database backup to your local machine:

First cd into the project directory:

```bash
cd ~/PythonAnywhere/nickmoreton.co.uk # use your own project directory
```

Then run the following command:

```bash
scp *your-account-name*@ssh.eu.pythonanywhere.com:~/dbbackups/*your-database-name*.sql ./dbbackups/*your-database-name*.sql
```

**Update your .gitignore file** so the backups don't get committed, to ignore the database backup directory (dbbackups) run the following commend:

```bash
echo "/dbbackups" >> .gitignore
```

#### Restore the database to your local machine

You'll need to make sure the docker instance of `Mysql` is running locally.

> If you database name is different then substitute `webapp` for your database name.
>
> Replace `/var/www/sites/nickmoreton.co.uk` with the path to your project directory on PythonAnywhere.

Open the `docker-compose.yml` file and add a new location of `./dbbackups:/dbbackups` to the `volumes` section:

```yaml
volumes:
  - dbdata:/var/lib/mysql
  - ./dbbackups:/dbbackups # add this line
```

> When you run docker-compose up again the directory and contents will be copied into the container.

Then run the following commands:

```bash
docker-compose up -d
# drop the existing database
docker-compose exec db mysql -u root -p -e "drop database webapp"
# create a new database
docker-compose exec db mysql -u root -p -e "create database webapp"
# import the database backup, it was copied form the local machine to the container
docker-compose exec db bash -c "mysql -u root -p webapp < /dbbackups/*your-database-name*.sql"
```

If you have `Adminer` running locally you can use that to drop the database, create it again and import the backup.

### Media files backup and restore

These commands can be used to copy the media files from the live site to your local machine.

First cd into the project directory on your local machine:

```bash
cd ~/PythonAnywhere/nickmoreton.co.uk # use your own project directory
```

Ensure the media directory exists:

```bash
mkdir -p ./media
```

Then run the following command:

```bash
scp -r *your-account-name*@ssh.eu.pythonanywhere.com:/var/www/sites/nickmoreton.co.uk/media ./
```
