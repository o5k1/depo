#!/usr/bin/env bash

# show MESSAGE while running COMMAND, COMMAND stdout is hidden
run_command() {
  COMMAND="$1"
  MESSAGE="$2"

  echo "$MESSAGE" && $COMMAND >/dev/null
}

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

# avoid editor invocation for merge
export GIT_MERGE_AUTOEDIT=no

# Format the given version as Git tag
VERSION="v$1"
SENTRY_VERSION="depo@$VERSION"

export SENTRY_ORG=reffable
export SENTRY_PROJECT=depo

# import var from .env file
run_command "cat .env"

run_command "git checkout develop" "changing branch to develop ..."

run_command "git flow release start '$VERSION'" "creating release '$VERSION' ..."

run_command "npm --no-git-tag-version version $VERSION" "updating package.json version ..."

# commit package.json with new version
git add package.json && git commit -m "update package.json version to '$VERSION'"

run_command "sentry-cli releases new $SENTRY_VERSION" "creating Sentry release '$SENTRY_VERSION' ..."

run_command "npm run build" "building '$VERSION' ..."

# commit build output
git add index.html && git commit -m 'build'

run_command "sentry-cli releases set-commits $SENTRY_VERSION --auto" "associating commits with Sentry release '$SENTRY_VERSION' ..."

run_command "git flow release finish -m '$VERSION'" "finishing release '$VERSION' ..."

unset GIT_MERGE_AUTOEDIT

run_command "git push -u origin master --tags" "pushing master ..."

#perchè ssh funzioni bisogna abilitare bitbucket clone tramite ssh, non https come è ora

#ssh 64.225.106.100 'cd /var/www/reffable.com/; git pull'

#echo "finalizing Sentry release '$SENTRY_VERSION' ..." && sentry-cli releases finalize "$SENTRY_VERSION"

run_command "sentry-cli releases finalize $SENTRY_VERSION" "finalizing Sentry release '$SENTRY_VERSION' ..."

echo "Deploy completed."



