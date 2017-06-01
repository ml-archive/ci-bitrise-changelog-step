#!/bin/bash

# fail if any command fails
set -e

latest_tag=`git describe --tags`
previous_tag="$(git describe --abbrev=0 --tags $(git rev-list --tags --skip=1 --max-count=1))"
changelog="Empty changelog"
committer="Build triggered from: $(git log --pretty=format:"%ce" HEAD^..HEAD)"

if [[ ! -z "$previous_tag" ]] && [[ ! -z "$latest_tag" ]] ; then
    changelog="$(git log --pretty=format:" - %s (%ce - %cD)" $latest_tag...$previous_tag)"    
elif [[ ! -z "$latest_tag" ]] ; then
    changelog="$(git log --pretty=format:" - %s (%ce - %cD)")"
else
    echo "No latest tag specified!"
    exit 1
fi

echo "Committer: $committer"
echo "Latest tag: $latest_tag"
echo "Previous tag: $previous_tag"
echo "Changelog: $changelog"

envman add --key COMMIT_CHANGELOG --value "$changelog"

exit 0
