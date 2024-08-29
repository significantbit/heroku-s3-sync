FROM node:18-buster

# Install system dependencies including Heroku CLI and AWS CLI
RUN apt-get update && \
    apt-get install -y \
        bash \
        curl \
        sudo \
        postgresql-client \
        awscli && \
    rm -rf /var/lib/apt/lists/*

# Download and install Heroku CLI
RUN curl -s https://cli-assets.heroku.com/install.sh | sh && \
    echo "✅ Heroku CLI installed" || echo "❌ Heroku CLI installation failed"

# Check and output AWS CLI installation details
RUN aws --version && \
    which aws && \
    ls -l /usr/bin/aws && \
    echo "✅ AWS CLI installation verified" || echo "❌ AWS CLI installation verification failed"

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY heroku.sh /heroku.sh
RUN chmod +x /heroku.sh

COPY s3.sh /s3.sh
RUN chmod +x /s3.sh

ENTRYPOINT ["/entrypoint.sh"]
