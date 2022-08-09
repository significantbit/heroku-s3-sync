#!/bin/sh -l

# Validate inputs
if [ -z "$INPUT_HEROKU_API_KEY" ] || [ -z "$INPUT_HEROKU_APP_PRODUCTION" ] || [ -z "$INPUT_HEROKU_APP_STAGING" ]; then
  printf "\n🚫  Heroku database syncronization failed.\n"
  printf "    Please provide 'heroku_app_production' and 'heroku_app_staging' to your Github action.\n\n"
  exit 1
fi

# Download Heroku CLI
curl -s https://cli-assets.heroku.com/install.sh | sh
printf "\n✅ Heroku CLI installed\n\n"

# Verify authorization
export HEROKU_API_KEY="$INPUT_HEROKU_API_KEY"
heroku auth:whoami > /dev/null 2>&1

if [ $? -ne 0 ]; then
  printf "\n🚫  Heroku database syncronization failed.\n"
  printf "    Unable to authorize using HEROKU_API_KEY.\n\n"
  exit 1
fi

LAST_BACKUP_DATE="$(heroku pg:backups:info -a ${INPUT_HEROKU_APP_PRODUCTION} | grep -o -E -m 1 '[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}')"

if [ -n "$INPUT_HEROKU_CREATE_BACKUP" ] || [ -z "$LAST_BACKUP_DATE" ]; then
  printf "✨ Capturing new database backup on ${INPUT_HEROKU_APP_PRODUCTION}...\n\n"

  # Create production database backup
  export HEROKU_APP=${INPUT_HEROKU_APP_PRODUCTION}
  heroku pg:backups:capture

  printf "\n✅ Production database backup captured\n\n"
else
  printf "⏭  Reusing existing backup on ${INPUT_HEROKU_APP_PRODUCTION} from $LAST_BACKUP_DATE\n\n"
fi

# Restore production database backup to staging
printf "✨ Restoring database backup to ${INPUT_HEROKU_APP_STAGING}...\n\n"
export HEROKU_APP=${INPUT_HEROKU_APP_STAGING}
heroku pg:backups:restore ${INPUT_HEROKU_APP_PRODUCTION}:: DATABASE_URL --confirm ${INPUT_HEROKU_APP_STAGING}
printf "\n✅ Production database backup restored to ${INPUT_HEROKU_APP_STAGING}\n"