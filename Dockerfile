# Use Ubuntu as the base image
FROM ubuntu:20.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    python3-pip \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf aws awscliv2.zip

# Install Heroku CLI
RUN curl https://cli-assets.heroku.com/install.sh | sh

# Set up working directory
WORKDIR /app

# Copy your scripts
COPY heroku.sh /app/heroku.sh
COPY s3.sh /app/s3.sh

# Make scripts executable
RUN chmod +x /app/heroku.sh /app/s3.sh

# Set entrypoint
CMD ["/bin/bash", "-c", "./heroku.sh && ./s3.sh"]
