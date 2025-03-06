FROM ruby:3.4.2

RUN apt-get update -qq && apt-get install -y nodejs npm postgresql-client

WORKDIR /app

COPY Gemfile /app/Gemfile

COPY Gemfile.lock /app/Gemfile.lock

RUN bundle install

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]