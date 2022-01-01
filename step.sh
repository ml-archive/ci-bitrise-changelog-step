#!/bin/bash

# Fail if any command fails
set -e

# Read all tags, separate them into an array
all_tags=`git tag -l | wc -l`

if [ $all_tags = 0 ]; then
    # No tags, exit.
    echo "Repository contains no tags. Please make a tag first."
    exit 1
elif [ $all_tags = 1 ]; then
    echo "Fetching commits since first commit."
    # We have first tag, fetch since first commit (ie. don't specify previous tag)
    
    changelog="$(git log --pretty=format:"$git_log_format") --date=format:"%Y-%m-%d %H:%M:%S""
else 
    echo "Fetching commits since last tag."

    # We have many tags, fetch since last one
    latest_tag=`git describe --tags`
    previous_tag="$(git describe --abbrev=0 --tags $(git rev-list --tags --skip=1 --max-count=1))"

    # Get commit messages since previous tag
    changelog="$(git log --pretty=format:"$git_log_format" --date=format:"%Y-%m-%d %H:%M:%S" $latest_tag...$previous_tag)"
fi

# Add branch info
branch="$(git branch --contains ${GIT_CLONE_COMMIT_HASH})"
branch=${branch:2}
NEWLINE=$'\n'
if [ -n "$branch" ]; then
    if [[ "$branch" == *"feature"* ]]; then
        branchinfo="*_WARNING_*: This is a _FEATURE_ build on *${branch}*${NEWLINE}${NEWLINE}" 
        changelog=$branchinfo$changelog
    elif [[ "$branch" == *"hotfix"* ]]; then
        branchinfo="*_WARNING_*: This is a _HOTFIX_ build on *${branch}*${NEWLINE}${NEWLINE}"
        changelog=$branchinfo$changelog
    else
        branchinfo="Built on *${branch}*${NEWLINE}${NEWLINE}"
        changelog=$branchinfo$changelog
    fi
fi

# Output collected information
echo "Committer: $(git log --pretty=format:"%ce" HEAD^..HEAD)"
echo "Latest tag: $latest_tag"
echo "Previous tag: $previous_tag"
echo "Changelog:"
echo "$changelog"

# Set environment variable for bitrise
envman add --key COMMIT_CHANGELOG --value "$changelog"

exit 0
