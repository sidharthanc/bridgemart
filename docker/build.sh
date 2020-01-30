#! /bin/bash
# This script is just a convience for local docker development and not called
# by any automated process

docker build --pull -f docker/Dockerfile.build -t bridge-rails-build .
# docker login to bridgepurchasing.azurecr.io then I can add --pull below
docker build -f docker/Dockerfile.dev -t bridge-rails-dev .

