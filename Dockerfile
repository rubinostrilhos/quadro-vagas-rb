FROM ruby:3.4.2

RUN apt update && apt upgrade -y && apt install -y lsb-base lsb-release curl ca-certificates && install -d /usr/share/postgresql-common/pgdg

RUN apt update && apt install -y libpq-dev watchman make chromium

ADD . /app
WORKDIR /app

RUN bundle install
