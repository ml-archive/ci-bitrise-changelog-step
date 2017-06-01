#!/bin/bash

latest_tag=`git describe --tags`
previous_tag="$(git describe --abbrev=0 --tags $(git rev-list --tags --skip=1 --max-count=1))"
changelog="Empty changelog"
committer="Build triggered from: $(git log --pretty=format:"%ce" HEAD^..HEAD)"

if [[ $previous_tag ]] && [[ $latest_tag ]]
then
    changelog="$(git log --pretty=format:" - %s (%ce - %cD)" $latest_tag...$previous_tag)"    
elif [[ $latest_tag ]]
then
    changelog="$(git log --pretty=format:" - %s (%ce - %cD)")"    
fi

echo "Committer: $committer"
echo "Latest tag: $latest_tag"
echo "Previous tag: $previous_tag"
echo "Changelog: $changelog"

envman add --key COMMIT_CHANGELOG --value $changelog

exit 0
