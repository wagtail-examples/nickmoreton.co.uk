# Run Dokku on OrbStack

This will set up dokku on a debian machine using orbstack.

Use it as a local development environment or for testing, not in DEBUG mode. It's trying to be as close to a heroku environment as possible.

The key objectives are:
- Use the same buildpacks as heroku (not deploying using Dockerfile)
- Use a storage system locally and not requiring s3 (not really like Heoku though)
- Use a postgres database
- Use a local domain name with https (not using a port)
- Use git push to deploy

---
- [Create a new machine](#create-a-machine) with the name `dokku-machine` and the domain name `dokku-machine.orb.local`.
- [Intall Dokku](#install-dokku) on the machine.
- [Configure the global domain](#configure-global-domain) to match the machine domain name.
- [SSH key](#ssh-key) to access the machine.
- [Install Postgres](#install-postgres) on the machine.
- [Create a new app](#create-a-new-app) on the machine.
- [Deploying to Dokku](#deploying-to-dokku) using git.
- [Accessing the app](#accessing-the-app) using the domain name.
- [Troubleshooting](#troubleshooting)
- - [Images and documents cannot be uploaded](#images-and-documents-cannot-be-uploaded) if you have issues with uploading images or documents.


## Prerequisites
- [OrbStack](https://orbstack.dev/) installed

## Create A Machine

```bash
orbctl create --arch amd64 --user root debian:bookworm dokku-machine
# wget is required for the dokku install
orbctl run -m dokku-machine -u root bash -c "apt install wget htop -y"
```

### Install Dokku

You could run the commands inside the machine console, logged in as root. That should translate to running the same commands below but moitting `orbctl run -m dokku-machine -u root bash -c`.

```bash
# Make sure the latest version is used
orbctl run -m dokku-machine -u root bash -c "wget -NP . https://dokku.com/install/v0.35.16/bootstrap.sh && sudo DOKKU_TAG=v0.35.16 bash bootstrap.sh"
```

### Configure Global Domain

This should match the machine Domain name in orbstack.

```bash
### Configure Domain

```bash
orbctl run -m dokku-machine -u root bash -c "dokku domains:set-global dokku-machine.orb.local"
# -----> Set dokku-machine.orb.local
```


### SSH Key

```bash
orbctl run -m dokku-machine -u root bash -c "echo 'your-ssh-key' | dokku ssh-keys:add admin"
# SHA256:j3xU+dszYsIv...
```

### Install Postgres

```bash
orbctl run -m dokku-machine -u root bash -c "dokku plugin:install https://github.com/dokku/dokku-postgres.git"
# Takes a little while to install
# -----> Priming bash-completion cache
```

## Create A New App

```bash
orbctl run -m dokku-machine -u root bash -c "dokku apps:create myapp"
# -----> Creating myapp...
# -----> Creating new app virtual host file...

orbctl run -m dokku-machine -u root bash -c "dokku postgres:create myapp-db"
# =====> Postgres container created: myapp-db

orbctl run -m dokku-machine -u root bash -c "dokku postgres:link myapp-db myapp"
# -----> Restarting app myapp
# !     App image (dokku/myapp:latest) not found

# Domians might need checking here and corrccted at the end
orbctl run -m dokku-machine -u root bash -c "dokku domains:report myapp"
# =====> myapp domains information
# ...

orbctl run -m dokku-machine -u root bash -c "dokku buildpacks:add myapp https://github.com/heroku/heroku-buildpack-nodejs.git"
orbctl run -m dokku-machine -u root bash -c "dokku buildpacks:add myapp https://github.com/heroku/heroku-buildpack-python.git"
# No feedback seen here

orbctl run -m dokku-machine -u root bash -c "dokku config:set myapp DJANGO_SECRET_KEY=supersecretkey --no-restart"
orbctl run -m dokku-machine -u root bash -c "dokku config:set myapp DJANGO_ALLOWED_HOSTS=myapp.dokku-machine.orb.local --no-restart"
orbctl run -m dokku-machine -u root bash -c "dokku config:set myapp DJANGO_CSRF_TRUSTED_ORIGINS=https://myapp.dokku-machine.orb.local --no-restart"
# -----> Setting config vars
# ...

orbctl run -m dokku-machine -u root bash -c "dokku storage:ensure-directory myapp --chown herokuish"
# -----> Ensuring /var/lib/dokku/data/storage/myapp exists

orbctl run -m dokku-machine -u root bash -c "dokku storage:mount myapp /var/lib/dokku/data/storage/myapp/media:/app/media"
# No feeback seen here optionally check with
orbctl run -m dokku-machine -u root bash -c "dokku storage:report myapp"

orbctl run -m dokku-machine -u root bash -c "mkdir -p /home/dokku/myapp/nginx.conf.d"
orbctl run -m dokku-machine -u root bash -c "cat <<EOF > /home/dokku/myapp/nginx.conf.d/media.conf
location /media {
    alias /var/lib/dokku/data/storage/myapp/media;
}
EOF"
# No feedback seen here optoanlly check with
orbctl run -m dokku-machine -u root bash -c "ls /home/dokku/myapp/nginx.conf.d"
# media.conf
orbctl run -m dokku-machine -u root bash -c "cat /home/dokku/myapp/nginx.conf.d/media.conf"
# location /media {
#    alias /var/lib/dokku/data/storage/myapp/media;
#}

# Set the upload size limit
orbctl run -m dokku-machine -u root bash -c "dokku nginx:set myapp client-max-body-size 10m"
# =====> Setting client-max-body-size to 10m

# Make any other corrections here

# Restart the app for all setting to take effect
# But this may not have any effect untill the app is deployed
orbctl run -m dokku-machine -u root bash -c "dokku ps:restart myapp"
# After the app is deployed the restart wlll happen automatically
```

## Deploying to Dokku

From the root of the project:

```bash
# only required once
git remote add dokku dokku@dokku-machine@orb:myapp
git remote -v # to check (optional)

# On the first deployemnt the app should be restarted so will capture any of the above changes
git push dokku main
# =====> Application deployed:
#        http://myapp.dokku-machine.orb.local
# and optional command to deploy could be
git push dokku current_branch_name:main

# now you will need to set an admin user login
orbctl run -m dokku-machine -u root bash -c "dokku enter myapp"
# Inside the container
./manage.py createsuperuser
# If need be other commands could be run here
# Exit the container
```

## Accessing the App
You should be able to access the app at `https://myapp.dokku-machine.orb.local` and the admin at `https://myapp.dokku-machine.orb.local/admin`.

## Troubleshooting

### Images and documents cannot be uploaded

This is likely due to the persmissions of the storage directory. You can check the permissions with:

```bash
orbctl run -m dokku-machine -u root bash -c "ls -l /var/lib/dokku/data/storage/myapp"
# drwxr-xr-x 1 root  root   0 Apr  2 17:08 media
# The media directory should be owned by the user `32767` and group `32767`

# If required you can change the permissions with:
orbctl run -m dokku-machine -u root bash -c "dokku storage:ensure-directory myapp --chown herokuish"
# -----> Ensuring /var/lib/dokku/data/storage/myapp exists
#        Setting directory ownership to 32767:32767
#        Directory ready for mounting

orbctl run -m dokku-machine -u root bash -c "ls -l /var/lib/dokku/data/storage/myapp"
# drwxr-xr-x 1 32767 32767  0 Apr  2 17:08 media
```

And try uploading again.

## Bonus

Thats a lot of commands to run. You can run the following script to do it all for you. 

[dokku-setup.sh](./files/dokku-setup.sh) Just make sure to change the `ssh-key` variables.

```bash
# Run it with
bash ./docs/files/dokku-setup.sh
