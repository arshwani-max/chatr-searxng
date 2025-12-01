# Ensure the base image is Python 3.11-slim

# Install system dependencies needed to build psycopg2
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        build-essential \
        libpq-dev \
        python3-dev \
    && pip install --no-cache-dir psycopg2-binary \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*