# Use a base image with Python since AWS CLI requires Python
FROM python:3.9-slim

# Install dependencies for AWS CLI and Heroku CLI
RUN apt-get update && \
    apt-get install -y curl gnupg

# Install AWS CLI
RUN pip install --no-cache-dir awscli

# Install Heroku CLI
RUN curl https://cli-assets.heroku.com/install.sh | sh

# Copy the shell scripts into the container
COPY heroku.sh /usr/local/bin/heroku.sh
COPY s3.sh /usr/local/bin/s3.sh

# Make the scripts executable
RUN chmod +x /usr/local/bin/heroku.sh /usr/local/bin/s3.sh

# Run the shell scripts
CMD ["/bin/sh", "-c", "/usr/local/bin/heroku.sh && /usr/local/bin/s3.sh"]

