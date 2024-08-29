FROM node:18-alpine

RUN apk add --no-cache bash curl gcompat sudo postgresql-client python3 py3-pip

# Create a virtual environment and install Python packages
RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir awscli

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