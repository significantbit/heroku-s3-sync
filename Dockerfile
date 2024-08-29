FROM node:18-alpine

# Install system dependencies
RUN apk add --no-cache bash curl gcompat sudo postgresql-client python3 py3-pip

# Set up Python virtual environment and install packages
RUN python3 -m venv /venv && \
    . /venv/bin/activate && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir awscli

# Set the virtual environment path for subsequent commands
ENV PATH="/venv/bin:$PATH"

# Verify installation
RUN aws --version

# Clean up
RUN rm -rf /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY heroku.sh /heroku.sh
RUN chmod +x /heroku.sh

COPY s3.sh /s3.sh
RUN chmod +x /s3.sh

ENTRYPOINT ["/entrypoint.sh"]
