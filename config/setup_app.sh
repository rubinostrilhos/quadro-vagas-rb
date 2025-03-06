#! /bin/sh

set -e

# yarn install

bundle check || bundle install --jobs 5 --retry 5

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

rails db:prepare
gem install foreman
foreman start -f Procfile.dev