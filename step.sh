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
    
    if [ -n "${push}" -a "${markdown_output}" == "true" ]; then
        changelog="$(git log --pretty=format:" - %s (%cr) _<%ce>_")"
    else
        changelog="$(git log --pretty=format:" - %s (%cr) _<%ce>_")"
    fi
else 
    echo "Fetching commits since last tag."

    # We have many tags, fetch since last one
    latest_tag=`git describe --tags`
    previous_tag="$(git describe --abbrev=0 --tags $(git rev-list --tags --skip=1 --max-count=1))"

    # Get commit messages since previous tag
    if [ -n "${push}" -a "${markdown_output}" == "true" ]; then
        changelog="$(git log --pretty=format:" - %s (%cr) _<%ce>_" $latest_tag...$previous_tag)"    
    else
        changelog="$(git log --pretty=format:"%s  (%cr) _<%ce>_" $latest_tag...$previous_tag)"    
    fi

fi

# Add branch info
NEWLINE=$'\n'
if [ -n "${BITRISE_GIT_BRANCH}" -a "${BITRISE_GIT_BRANCH}" == *"feature"* ]; then
    branchinfo="*_WARNING_*: This is a _FEATURE_ build on *${BITRISE_GIT_BRANCH}*${NEWLINE}" 
    changelog=$branchinfo$changelog
elif [ -n "${BITRISE_GIT_BRANCH}" -a "${BITRISE_GIT_BRANCH}" == *"hotfix"* ]; then
    branchinfo="*_WARNING_*: This is a _HOTFIX_ build on *${BITRISE_GIT_BRANCH}*${NEWLINE}"
    changelog=$branchinfo$changelog
else
    branchinfo="Built on *${BITRISE_GIT_BRANCH}*${NEWLINE}"
    changelog=$branchinfo$changelog
if

# Output collected information
echo "Committer: $(git log --pretty=format:"%ce" HEAD^..HEAD)"
echo "Latest tag: $latest_tag"
echo "Previous tag: $previous_tag"
echo "Changelog:"
echo "$changelog"

# Set environment variable for bitrise
envman add --key COMMIT_CHANGELOG --value "$changelog"

exit 0
