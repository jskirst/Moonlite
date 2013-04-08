#! /bin/bash

heroku pgbackups:capture --remote production --expire
curl -o ../latest_moonlite.dump `heroku pgbackups:url --remote production`