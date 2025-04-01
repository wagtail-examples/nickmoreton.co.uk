# Fresh Dokku Setup

ssh into the server as `root`

## Install dokku

https://dokku.com/docs/getting-started/installation/

- Update and upgrade the server
- Install `wget` and `htop`

```bash
wget -NP . https://dokku.com/install/[DOKKU_VERSION]/bootstrap.sh
DOKKU_TAG=[DOKKU_VERSION] bash bootstrap.sh
```

### Setup ssh keys

```bash
# Add the public key to the server
ssh-copy-id -i ~/.ssh/[key-file].pub root@[server-ip]
# Add the public key to dokku
# usually your key is already available under the current user's `~/.ssh/authorized_keys` file
cat ~/.ssh/authorized_keys | dokku ssh-keys:add admin
```

### Setup domain

```bash
# you can use any domain you already have access to
# this domain should have an A record or CNAME pointing at your server's IP
dokku domains:set-global [domain-name]
```

### Install postgres

https://github.com/dokku/dokku-postgres

```bash
# on the Dokku host
# install the postgres plugin
# plugin installation requires root, hence the user change
sudo dokku plugin:install https://github.com/dokku/dokku-postgres.git
```

### Install Letsencrypt

https://github.com/dokku/dokku-letsencrypt

```bash
sudo dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git
sudo dokku letsencrypt:cron-job --add # <- To enable auto-renew
```

## Create a new app and link it to a postgres database

```bash
dokku apps:create nickmoreton-staging
dokku postgres:create nickmoreton-staging
dokku postgres:link nickmoreton-staging nickmoreton-staging
```

## Set up the apps environment variables
```bash
dokku config:set nickmoreton-staging DJANGO_SECRET_KEY=supersecretkey --no-restart
dokku config:set nickmoreton-staging DJANGO_ALLOWED_HOSTS=the-domain-in-use --no-restart
dokku config:set nickmoreton-staging DJANGO_CSRF_TRUSTED_ORIGINS=https://the-domain-in-use --no-restart
```

## Ensure the app storage directory exists
```bash
# The permissions are set to 32767:32767
dokku storage:ensure-directory nickmoreton-staging --chown herokuish
# Sometimes the above command fails, so run this to ensure the directory exists
# and is owned by the correct user

# Mount the apps storage directory
dokku storage:mount nickmoreton-staging /var/lib/dokku/data/storage/nickmoreton-staging/media:/app/media
```

## Set up the herokuish buildpacks

No docker file in production... the order matters, node first, then python

```bash
dokku buildpacks:clear nickmoreton-staging
dokku buildpacks:add nickmoreton-staging https://github.com/heroku/heroku-buildpack-nodejs.git
dokku buildpacks:add nickmoreton-staging https://github.com/heroku/heroku-buildpack-python.git
```

# Set the ports for the app
By default it gets set to http:8000:8000 

```bash
dokku ports:add or set nickmoreton-staging https:80:8000
# example output
# dokku ports:report nickmoreton-staging
# =====> nickmoreton-staging ports information
#        Ports map:                     http:80:8000 https:443:8000
#        Ports map detected:            http:80:5000 https:443:5000
```

## Add an nginx config file for the apps media files

```bash
mkdir -p /home/dokku/nickmoreton-staging/nginx.conf.d
```

Add a file with the following content to the directory:

```bash
cat <<EOL > /home/dokku/nickmoreton-staging/nginx.conf.d/media.conf
location /media {
    alias /var/lib/dokku/data/storage/nickmoreton-staging/media;
}
```
Run the following command to set the nginx config
```bash
dokku ps:restart nickmoreton-staging
service nginx reload
```

Adjust the nginx config for uploads:

```bash
dokku nginx:set nickmoreton-staging client-max-body-size 10m
dokku proxy:build-config nickmoreton-staging # for settings to take effect
```
## Set up the letsencrypt certificate

```bash
dokku letsencrypt:enable nickmoreton-staging
dokku letsencrypt:cron-job --add
dokku letsencrypt:list # to check the status
```