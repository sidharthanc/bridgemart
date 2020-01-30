# URLS must have their username and password fields percent-escaped (e.g ruby> CGI.escape('bridgeadmin@bridge-db-staging'))

kubectl create secret generic env-credentials \
  --from-literal=REDIS_URL='redis://:AqjjqWWYOVegzE+s296lgGNYb9bD0Vvnpfj9lge3Yic=@bridge-dev.redis.cache.windows.net:6380' \
  --from-literal=DATABASE_URL='postgres://bridgeadmin%40bridge-db-staging:i*[!y=)(D2dG=@bridge-db-staging.postgres.database.azure.com/bridgemart-dev'

# Edit with kubectl edit secrets env-credentials
# values must be base64 encoded, so the data value should be 
# > echo -n '1f2d1e2e67df' | base64
# > MWYyZDFlMmU2N2Rm

# in Addition, usernames and passwords should be percent-escaped, eg.
# ruby> CGI.escape('bridgeadmin@bridge-db-staging')




