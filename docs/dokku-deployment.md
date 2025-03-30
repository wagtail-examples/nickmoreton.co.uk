# Staging deployment only

Git is used to deploy the app to the staging server. 

## Add a git rmote

```bash
git add remote dokku dokku@[server-ip-or-doamin]:nickmoreton-staging
```

## Deploy to staging

```bash
git push dokku [local-branch]:main
```

The deploy process will run the following:

- Build the fontend and backend
- Run the migrations
- Collect the static files
- Restart the app
- Restart the nginx server

It should be working after this and a domain link should be shown.
