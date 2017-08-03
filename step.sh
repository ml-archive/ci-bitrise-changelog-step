#!/bin/bash

# Fail if any command fails
set -e

# Read all tags, separate them into an array
IFS='\n' read -r -a all_tags <<< "`git tag -l`"

if [ ${#all_tags[@]} = 0 ]; then
    # No tags, exit.
    echo "Reposiotry contains no tags. Please make a tag first."
    exit 1
elif [ ${#all_tags[@]} = 1 ]; then
    # We have first tag, fetch since first commit (ie. don't specify previous tag)
    latest_tag=`git describe --tags`
else 
    # We have many tags, fetch since last one
    latest_tag=`git describe --tags`
    previous_tag="$(git describe --abbrev=0 --tags $(git rev-list --tags --skip=1 --max-count=1))"
fi

changelog="Empty changelog"

if [[ ! -z "$previous_tag" ]] && [[ ! -z "$latest_tag" ]] ; then
    # Get commit messages since previous tag
    changelog="$(git log --pretty=format:" - %s (%ce - %cD)" $latest_tag...$previous_tag)"    

elif [[ ! -z "$latest_tag" ]] ; then
    # Get commit messages since first commit
    changelog="$(git log --pretty=format:" - %s (%ce - %cD)")"

else
    # This should never happen, but who knows? ¯\_(ツ)_/¯
    echo "No latest tag specified!"
    exit 1
fi

# Output colledcted information
echo "Committer: $(git log --pretty=format:"%ce" HEAD^..HEAD)"
echo "Latest tag: $latest_tag"
echo "Previous tag: $previous_tag"
echo "Changelog: $changelog"

# Set environment variable for bitrise
envman add --key COMMIT_CHANGELOG --value "$changelog"

exit 0
