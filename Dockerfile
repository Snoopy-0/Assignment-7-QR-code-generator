# Use the official Python image from DockerHub as the base image
FROM python:3.12-slim-bullseye

# Prevent Python from writing .pyc files and using stdout buffering
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Set the working directory inside the container
WORKDIR /app

# System deps (only if Pillow needs to build from source; safe on slim)
# If wheels work for you, you can delete this block.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libjpeg62-turbo-dev \
    zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

# Copy dependency list first to leverage layer caching
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Create directories for logs and QR codes, and set ownership to the non-root user
RUN useradd -m myuser && mkdir logs qr_codes && chown myuser:myuser logs qr_codes

# Copy the application source (owned by non-root)
COPY --chown=myuser:myuser . .

# Switch to the non-root user for security
USER myuser

# Default process
ENTRYPOINT ["python", "main.py"]
# Default args (can be overridden at `docker run`)
CMD ["--url", "http://github.com/kaw393939"]
