# Development only Dockerfile
# No need to build this image for production
# PythonAnywhere doesn't support Docker

# Use the official Python image
FROM python:3.10.5

# Keeps Python from generating .pyc files in the container
# Turns off buffering for easier container logging
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Copy the requirements file in order to install
COPY ./requirements.* .

# Install both production and development dependencies
# Use requirements.txt here to test it's working as it's used in production
RUN python -m pip install --upgrade pip && \
    pip install -r requirements.txt && \
    pip install -r requirements.dev.txt

# Create a user
RUN useradd nm --create-home && mkdir /app && chown -R nm /app

# Switch to this user
USER nm

# Set the working directory
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY --chown=nm . /app
