# bin/sh -i

bin/rails db:setup 

bin/rails db:migrate

if [ -f tmp/pids/server.pid ]; then
  rm -f tmp/pids/server.pid
fi

foreman start -f Procfile.dev