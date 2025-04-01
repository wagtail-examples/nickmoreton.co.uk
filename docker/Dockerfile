# Currently used for development only
# Heroku deployments are via buildpacks
FROM python:3.13-bookworm AS base

RUN useradd wagtail

EXPOSE 8000

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=8000

RUN apt-get update --yes --quiet && apt-get install --yes --quiet --no-install-recommends \
    build-essential \
    libpq-dev \
    libjpeg62-turbo-dev \
    zlib1g-dev \
    libwebp-dev \
 && rm -rf /var/lib/apt/lists/*

# Requirements.
COPY requirements.txt /
RUN pip install -U pip && pip install -r /requirements.txt

WORKDIR /app

RUN chown wagtail:wagtail /app

COPY --chown=wagtail:wagtail . .

USER wagtail

# RUN python manage.py collectstatic --noinput --clear

# FROM base AS development

# CMD tail -f /dev/null