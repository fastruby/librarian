ARG DISTRO_NAME=bullseye

FROM ruby:3.2.1-slim-$DISTRO_NAME

ARG DISTRO_NAME

RUN apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    gnupg2 \
    curl \
    less \
    openssh-client \
    git \
  && apt-get clean \
  && rm -rf /var/cache/apt/archives/* \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    libpq-dev \
    postgresql-client-$PG_MAJOR \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && truncate -s 0 /var/log/*log

# Install NodeJS and Yarn
ARG NODE_MAJOR
ARG YARN_VERSION
RUN curl -sL https://deb.nodesource.com/setup_$NODE_MAJOR.x | bash -
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    nodejs \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && truncate -s 0 /var/log/*log
RUN npm install -g yarn@$YARN_VERSION

WORKDIR /app

# Copy all the Gemfile files
COPY Gemfile* ./

RUN gem install bundler -v "$(tail -n 1 Gemfile.lock)"
RUN bundle install

# Add a script to be executed every time the container starts.
COPY bin/entrypoint.sh /usr/bin/
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Configure the main process to run when running the image
# CMD ["rails", "server", "-b", "0.0.0.0"]

# CMD ["/usr/bin/bash"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]