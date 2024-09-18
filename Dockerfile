FROM ruby:3.3.5

# Install packages and dev dependencies
ARG NODE_MAJOR=20
RUN apt-get install -y ca-certificates curl gnupg
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

RUN apt-get update -y

RUN apt-get update -qq && \ 
    apt-get install --no-install-recommends -y build-essential chromium curl libjemalloc2 libvips libpq-dev nodejs postgresql-client
RUN gem install foreman

# Set workdir
WORKDIR /ruby-vagas

# Install local dependencies
COPY Gemfile Gemfile.lock ./
COPY package.json ./
RUN corepack enable
RUN bundle install
RUN yarn install

COPY . .

RUN yarn build
RUN yarn build:css
