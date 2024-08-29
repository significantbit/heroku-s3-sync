# Use a base image with Python since AWS CLI requires Python
FROM python:3.9-slim

# Install dependencies including unzip and the requested packages
RUN apt-get update && \
    apt-get install -y curl gnupg unzip bash sudo postgresql-client && \
    # gcompat is not available in Debian-based systems, so we'll skip it
    # Install Node.js and npm
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download and install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    aws --version && \
    rm -rf aws awscliv2.zip

# Install Heroku CLI
RUN curl https://cli-assets.heroku.com/install.sh | sh && \
    heroku --version

# Copy the shell scripts into the container
COPY heroku.sh /usr/local/bin/heroku.sh
COPY s3.sh /usr/local/bin/s3.sh

# Make the scripts executable
RUN chmod +x /usr/local/bin/heroku.sh /usr/local/bin/s3.sh

# Run the shell scripts
CMD ["/bin/bash", "-c", "/usr/local/bin/heroku.sh && /usr/local/bin/s3.sh"]
