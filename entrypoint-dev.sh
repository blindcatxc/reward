#! /bin/bash

set -euo pipefail

echo "bundle install..."
bundle check || bundle install --jobs 4

echo "Checking Node Packages..."
yarn install

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
