#!/bin/sh -l

# Ensure the AWS CLI path is set
export PATH="/venv/bin:$PATH"

# Run the scripts
/heroku.sh
if [ $? -ne 0 ]; then
  echo "Heroku script failed"
  exit 1
fi

/s3.sh
if [ $? -ne 0 ]; then
  echo "S3 script failed"
  exit 1
fi