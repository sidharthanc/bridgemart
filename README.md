## Hello!

Just starting? Run these commands to finish setting up:

```
bundle
bundle binstub guard rspec-core sidekiq foreman puma
brew install nvm
```

Follow the instructions from the nvm install and source ~/.bash_profile

```
nvm install 9
nvm use 9.11.1
brew install yarn
yarn install
```

Edit the `config/master.key` by adding the secret key value from the BridgeMart Technical Document

```
bin/rails db:drop db:create db:migrate
bin/rspec
```

You might be checked out on the develop branch, if you are, do:

```
git checkout master
git flow init
```

Accept all defaults from the init prompts

```
git checkout develop
```

# During development, run the following:

`bin/guard` for local CI

`bin/foreman start web` for the Rails server


# Staging / Production (Azure)

Install the Azure CLI and K8s Dashboard
```
brew update && brew install azure-cli
az login  # Get creds from docs
az aks install-cli
az aks get-credentials --resource-group bridge --name bridge-rails
```