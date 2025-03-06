FROM ruby:3.4.2

RUN apt-get update -qq && apt-get install -y nodejs npm postgresql-client chromium libnss3 libgconf-2-4 libxi6 libgdk-pixbuf2.0-0 libxcomposite1 libasound2 libxrandr2 libatk1.0-0 libgtk-3-0 libxss1 libgbm1

RUN npm install -g yarn

WORKDIR /app

COPY Gemfile /app/Gemfile

COPY Gemfile.lock /app/Gemfile.lock

COPY . /app

RUN bundle install

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]