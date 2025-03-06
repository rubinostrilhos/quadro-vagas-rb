FROM ruby:3.4.2-slim-bullseye

RUN apt update
RUN apt upgrade -y

RUN apt update && apt install -y --no-install-recommends \
    build-essential \ 
    libpq-dev \
    libyaml-dev \
    libvips42 \
    chromium \
    chromium-driver 

ADD . /home/app/web
WORKDIR /home/app/web

RUN bundle install --jobs 5 --retry 5

RUN rails assets:precompile

CMD ["bin/rails", "server", "-p", "3000", "-b", "0.0.0.0"]

EXPOSE 3000