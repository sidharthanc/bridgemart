#! /bin/sh

IMAGE=bridgepurchasing.azurecr.io/bridge-rails:6cee349348afcf64e3f4d06965608f0302de5897 \
RAILS_MASTER_KEY=`cat config/master.key` \
RAILS_ENV=production \
REDIS_URL=redis://bridge-redis-prod.redis.cache.windows.net:6379 \
erb -T - config/deploy/containers.yml.erb | tee .k8s-manifest