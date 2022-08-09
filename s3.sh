#!/bin/sh -l

# Validate inuts
if [ -z "$INPUT_AWS_ACCESS_KEY_ID" ] || [ -z "$INPUT_AWS_SECRET_ACCESS_KEY" ] || [ -z "$INPUT_S3_BUCKET_PRODUCTION" ] || [ -z "$INPUT_S3_BUCKET_STAGING" ]; then
  printf "\n❌ Skipping S3 bucket syncronization.\n"
  printf "   Add 's3_bucket_production' and 's3_bucket_staging' to your Github action to enable it.\n\n"
  return
fi

# Create a dedicated profile for this action to avoid conflicts
aws configure --profile heroku-s3-sync <<-EOF > /dev/null 2>&1
${INPUT_AWS_ACCESS_KEY_ID}
${INPUT_AWS_SECRET_ACCESS_KEY}
${INPUT_AWS_REGION}
text
EOF

# Verify authorization
aws sts get-caller-identity --profile heroku-s3-sync > /dev/null

if [ $? -ne 0 ]; then
  printf "\n🚫  S3 syncronization failed.\n"
  printf "    Unable to authorize using AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY.\n\n"
  exit 1
fi

# Support --delete flag
if [ -n "$INPUT_S3_PURGE" ]; then
  DELETE_ARG="--delete"
fi

# Sync using our dedicated profile and suppress verbose messages
aws s3 sync s3://${INPUT_S3_BUCKET_PRODUCTION} s3://${INPUT_S3_BUCKET_STAGING} --profile heroku-s3-sync ${DELETE_ARG}

# Clear out credentials after we're done
aws configure --profile heroku-s3-sync <<-EOF > /dev/null 2>&1
null
null
null
text
EOF

printf "\n✅ S3 bucket syncronized"
if [ -n "$INPUT_S3_PURGE" ]; then
  printf " + purged"
fi
printf "\n\n"