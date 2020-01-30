#!/bin/sh
export CI=true
bin/rake db:migrate 2>/dev/null || bin/rake db:setup
yarn --silent install && bin/webpack
bundle exec rspec --exclude-pattern "spec/{requests}/**/*_spec.rb" --format progress --format RspecJunitFormatter --out log/test-rspec.xml
# xvfb-run -a bundle exec rspec --format progress --format RspecJunitFormatter --out log/test-rspec.xml
