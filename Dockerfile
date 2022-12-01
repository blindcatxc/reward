# Base stage contains things common to all later stages.
FROM ruby:3.1.2-slim as base

RUN apt-get update -qq && apt-get install -yq --no-install-recommends \
    build-essential \
    gnupg2 \
    less \
    git \
    libpq-dev \
    postgresql-client \
    curl

# Add NodeJS to sources list
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -

RUN apt-get update -qq && apt-get install -yq --no-install-recommends \
  nodejs \
  $(cat /tmp/Aptfile | xargs) \
  && apt-get clean \
	&& rm -rf /var/cache/apt/archives/* \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& truncate -s 0 /var/log/*log

# Enable built-in yarn
RUN corepack enable

ENV LANG=C.UTF-8 \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3

RUN gem update --system && gem install bundler

FROM base as dev

WORKDIR /usr/src/app

RUN useradd app-user -m \
	&& chown -R app-user:app-user /usr/src/app

COPY . ./
RUN bundle install --without development test && bundle clean --force

ENV RAILS_SERVE_STATIC_FILES=yes
ENV RAILS_LOG_TO_STDOUT=true
RUN bundle exec rails assets:precompile

ENV PORT=3000
EXPOSE ${PORT}

USER app-user
CMD []