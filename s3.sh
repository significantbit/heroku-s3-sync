#!/bin/sh -l

# Check if AWS CLI is installed
if ! aws --version 2>&1; then
    echo "❌ AWS CLI is not installed or not functioning properly."
    exit 1
fi

# Check AWS CLI version
AWS_VERSION=$(aws --version 2>&1)
echo "AWS CLI version: $AWS_VERSION"

# Validate inputs
if [ -z "$INPUT_AWS_ACCESS_KEY_ID" ] || [ -z "$INPUT_AWS_SECRET_ACCESS_KEY" ] || [ -z "$INPUT_S3_BUCKET_PRODUCTION" ] || [ -z "$INPUT_S3_BUCKET_STAGING" ]; then
  echo "\n❌ Skipping S3 bucket synchronization.\nAdd 's3_bucket_production' and 's3_bucket_staging' to your GitHub action to enable it.\n"
  exit 1
fi

# Create a dedicated profile for this action to avoid conflicts
aws configure --profile heroku-s3-sync <<-EOF > /dev/null 2>&1
${INPUT_AWS_ACCESS_KEY_ID}
${INPUT_AWS_SECRET_ACCESS_KEY}
${INPUT_AWS_REGION}
text
EOF

# Verify authorization
if ! aws sts get-caller-identity --profile heroku-s3-sync > /dev/null; then
  echo "\n🚫  S3 synchronization failed.\nUnable to authorize using AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY.\n"
  exit 1
fi

# Support --delete flag
DELETE_ARG=""
if [ "$INPUT_S3_PURGE" = "true" ]; then
  DELETE_ARG="--delete"
fi

# Sync using our dedicated profile and suppress verbose messages
if ! aws s3 sync s3://${INPUT_S3_BUCKET_PRODUCTION} s3://${INPUT_S3_BUCKET_STAGING} --profile heroku-s3-sync ${DELETE_ARG}; then
  echo "\n🚫  S3 synchronization failed.\nHave you set up IAM permissions to the specific bucket?\n"
  exit 1
fi

# Clear out credentials after we're done
aws configure --profile heroku-s3-sync <<-EOF > /dev/null 2>&1
null
null
null
text
EOF

echo "\n✅ S3 bucket synchronized"
if [ "$INPUT_S3_PURGE" = "true" ]; then
  echo " + purged"
fi
echo "\n"
