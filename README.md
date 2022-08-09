# Heroku + S3 sync
> ♻️ &nbsp;Sync Heroku Postgres database + S3 bucket to staging environment using Github actions.

## Example usage

```yaml
uses: significantbit/heroku-s3-sync
with:
  # Always store credentials as repository/organization secrets
  heroku_api_key: ${{ secrets.HEROKU_API_KEY }}
  aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID }}
  aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  # Heroku apps
  heroku_app_production: my-site-production
  heroku_app_staging: my-site-staging
  # Create a new database backup, otherwise the latest will be used (default: true)
  heroku_create_backup: true
  # S3 buckets setting
  s3_bucket_production: my-site-production
  s3_bucket_staging: my-site-staging
  # Purge old files from staging bucket (default: true)
  s3_purge: true
```

### Repository secrets
```sh
# Create API key using 'heroku authorizations:create' on your local machine
HEROKU_API_KEY=

# AWS IAM user credentials
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
```