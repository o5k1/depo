#!/usr/bin/env bash

# check if git-flow command installed
git-flow &>/dev/null

if [[ "$?" -ne 1 ]]; then
  echo "ERROR: Missing git-flow. Check https://github.com/petervanderdoes/gitflow-avh/wiki/Installation"
  exit 1
fi

# check if sentry-cli command installed
sentry-cli &>/dev/null

if [[ "$?" -ne 1 ]]; then
  echo "ERROR: Missing sentry-cli. Check https://github.com/getsentry/sentry-cli"
  exit 1
fi

# Check if version passed as argument
if [[ -z "$1" ]]; then
   echo "ERROR: Missing version number. Please provide one like 1.0.0"
   exit 1
fi

# exit when any command fails
set -e

# Format the given version as Git tag
VERSION="v$1"
SENTRY_VERSION="reffable_web-'$VERSION'"

echo "changing branch to develop ..." && git checkout develop

echo "creating release '$VERSION' ..." && git flow release start "$VERSION"

#echo "creating Sentry release '$SENTRY_VERSION' ..." && sentry-cli releases new "$SENTRY_VERSION"

#echo "building '$VERSION' ..." && npm run build

#echo "associating commints with Sentry release '$SENTRY_VERSION' ..." && sentry-cli releases set-commits "$SENTRY_VERSION" --auto

echo "finishing release '$VERSION' ..." && git flow release finish "$VERSION"

git push origin --tags

#perchè ssh funzioni bisogna abilitare bitbucket clone tramite ssh, non https come è ora

#ssh 64.225.106.100 'cd /var/www/reffable.com/; git pull'

#echo "finalizing Sentry release '$SENTRY_VERSION' ..." && sentry-cli releases finalize "$SENTRY_VERSION"

echo "Deploy completed."

