#! /bin/sh

# If database exists, migrate. Otherwise setup (create and seed)
bundle exec rake db:migrate 2>/dev/null || bundle exec rake db:setup
echo "Done!"