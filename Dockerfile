FROM python:3.10.5

    # Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1 \
    # Turns off buffering for easier container logging
    PYTHONUNBUFFERED=1

    # Install any needed packages specified in requirements.txt
COPY requirements.txt ./

RUN python -m pip install --upgrade pip && \
    pip install -r requirements.txt

    # Create a user
RUN useradd nm --create-home && mkdir /app && chown -R nm /app

    # Switch to this user
USER nm

    # Set the working directory
WORKDIR /app

    # Copy the current directory contents into the container at /app
COPY --chown=vds . /app
