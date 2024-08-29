# Use a base image with Python since AWS CLI requires Python
FROM python:3.9-slim

# Install dependencies including unzip
RUN apt-get update && \
    apt-get install -y curl gnupg unzip

# Download and install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    sudo ./aws/install && \
    aws --version

# Install Heroku CLI
RUN curl https://cli-assets.heroku.com/install.sh | sh && \
    heroku --version

# Copy the shell scripts into the container
COPY heroku.sh /usr/local/bin/heroku.sh
COPY s3.sh /usr/local/bin/s3.sh

# Make the scripts executable
RUN chmod +x /usr/local/bin/heroku.sh /usr/local/bin/s3.sh

# Run the shell scripts
CMD ["/bin/sh", "-c", "/usr/local/bin/heroku.sh && /usr/local/bin/s3.sh"]
