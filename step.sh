#!/bin/bash

# Fail if any command fails
set -e

# Read all tags, separate them into an array
all_tags=`git tag -l | wc -l`
divider_line="------\n"

format_commit_message() {
    local msg
    msg=$(echo $1 | xargs echo -n)
    msg="$(tr '[:lower:]' '[:upper:]' <<< ${msg:0:1})${msg:1}"
    if [ -n "${markdown_output}" -a "${markdown_output}" == "yes" ]; then
        msg=" - $msg"   
    else
        msg="$msg"
    fi
    echo $msg
}

# Set date format from options
if test -n "${custom_dateformat}"; then
    dateformat=$custom_dateformat
else
    dateformat="%Y-%m-%d %H:%M:%S"
fi

# Set date format from options
if test -n "${pretty_git_format}"; then
    prettygitformat=$pretty_git_format
else
    #prettygitformat="%s (%cd) _<%ce>_"
    prettygitformat="%s (%cn)"
fi


if [ $all_tags = 0 ]; then
    # No tags, exit.
    echo "Repository contains no tags. Please make a tag first."
elif [ $all_tags = 1 ]; then
    echo "Fetching commits since first commit."
    # We have first tag, fetch since first commit (ie. don't specify previous tag)
    
    if [ -n "${markdown_output}" -a "${markdown_output}" == "yes" ]; then
        changelog="$(git log --no-merges --pretty=format:"$prettygitformat") --date=format:"$dateformat""
    else
        changelog="$(git log --no-merges --pretty=format:"$prettygitformat") --date=format:"$dateformat""
    fi
else 
    # We have many tags, fetch since last one
    latest_tag="$(git describe --abbrev=0 --tags $(git rev-list --tags --skip=0 --max-count=1))"
    previous_tag="$(git describe --abbrev=0 --tags $(git rev-list --tags --skip=1 --max-count=1))"

    echo "Fetching commits between $latest_tag and $previous_tag"

    # Get commit messages since previous tag
    if [ -n "${markdown_output}" -a "${markdown_output}" == "yes" ]; then
        changelog="$(git log --no-merges --pretty=format:"$prettygitformat" --date=format:"$dateformat" $latest_tag...$previous_tag)"    
    else
        changelog="$(git log --no-merges --pretty=format:"$prettygitformat" --date=format:"$dateformat" $latest_tag...$previous_tag)"    
    fi
fi

make_header() {
    completeChangelog=""

    if [ -n "${markdown_output}" -a "${markdown_output}" == "yes" ]; then
        completeChangelog+="#$latest_tag\n"
    else
        completeChangelog+="$latest_tag\n"
    fi
    completeChangelog+="$divider_line"
}

conventional_commit_changelog() {

    if [ -n "${markdown_output}" -a "${markdown_output}" == "yes" ]; then
        featureList="##"   
    else
        featureList=""
    fi

    if test -n "${custom_features_name}"; then
        featureList+="${custom_features_name}\n"
    else
        featureList+="🎉 Features\n"
    fi
    featureList+="$divider_line"

    if [ -n "${markdown_output}" -a "${markdown_output}" == "yes" ]; then
        fixList="##"   
    else
        fixList=""
    fi

    if test -n "${custom_bugfixes_name}"; then
        fixList+="${custom_bugfixes_name}\n"
    else
        fixList+="🐛 Bugfixes\n"
    fi
    fixList+="$divider_line"

    if [ -n "${markdown_output}" -a "${markdown_output}" == "yes" ]; then
        maintenanceList="##"   
    else
        maintenanceList=""
    fi

    if test -n "${custom_maintenance_name}"; then
        maintenanceList+="${custom_maintenance_name}\n"
    else
        maintenanceList+="🔨Improvements\n"
    fi
    maintenanceList+="$divider_line"

    if [ -n "${markdown_output}" -a "${markdown_output}" == "yes" ]; then
        formatList="##"   
    else
        formatList=""
    fi

    if test -n "${custom_format_name}"; then
        formatList+="${custom_format_name}\n"
    else
        formatList+="⚒ Formatting\n"
    fi
    formatList+="$divider_line"

    if [ -n "${markdown_output}" -a "${markdown_output}" == "yes" ]; then
        testList="##"   
    else
        testList=""
    fi

    if test -n "${custom_test_name}"; then
        testList+="${custom_test_name}\n"
    else
        testList+="📝 Tests\n"
    fi
    testList+="$divider_line"

    if [ -n "${markdown_output}" -a "${markdown_output}" == "yes" ]; then
        refactorList="##"   
    else
        refactorList=""
    fi

    if test -n "${custom_refactor_name}"; then
        refactorList+="${custom_refactor_name}\n"
    else
        refactorList+="🧹 Refactors\n"
    fi
    refactorList+="$divider_line"

    if [ -n "${markdown_output}" -a "${markdown_output}" == "yes" ]; then
        documentationList="##"   
    else
        documentationList=""
    fi

    if test -n "${custom_documentation_name}"; then
        documentationList+="${custom_documentation_name}\n"
    else
        documentationList+="📄 Documentation\n"
    fi
    documentationList+="$divider_line"

    if [ -n "${markdown_output}" -a "${markdown_output}" == "yes" ]; then
        otherList="##"   
    else
        otherList=""
    fi

    if test -n "${custom_other_name}"; then
        otherList+="${custom_other_name}\n"
    else
        otherList+="🤷 Other changes\n"
    fi
    otherList+="$divider_line"

    # case insensitive matching below
    shopt -s nocasematch

    # Strip prefixes and format commit messages
    while IFS= read -r line; do
        if [[ $line =~ ^(feat\((.*)\)|feat):(.*)$ ]]; then
            tmp="${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
            tmp=$(format_commit_message "$tmp")
            featureList+="$tmp\n"
        elif [[ $line =~ ^(feature\((.*)\)|feature):(.*)$ ]]; then
            tmp="${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
            tmp=$(format_commit_message "$tmp")
            featureList+="$tmp\n"
        elif [[ $line =~ ^(fix\((.*)\)|fix):(.*)$ ]]; then
        #elif [[ $line == fix:* ]]; then
            tmp="${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
            tmp=$(format_commit_message "$tmp")
            fixList+="$tmp\n"
        elif [[ $line =~ ^(bugfix\((.*)\)|bugfix):(.*)$ ]]; then
            tmp="${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
            tmp=$(format_commit_message "$tmp")
            fixList+="$tmp\n"
        elif [[ $line =~ ^(chore\((.*)\)|chore):(.*)$ ]]; then
            tmp="${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
            tmp=$(format_commit_message "$tmp")
            maintenanceList+="$tmp\n"
        elif [[ $line =~ ^(build\((.*)\)|build):(.*)$ ]]; then
            tmp="${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
            tmp=$(format_commit_message "$tmp")
            maintenanceList+="$tmp\n"
        elif [[ $line =~ ^(refactor\((.*)\)|refactor):(.*)$ ]]; then
            tmp="${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
            tmp=$(format_commit_message "$tmp")
            refactorList+="$tmp\n"
        elif [[ $line =~ ^(format\((.*)\)|format):(.*)$ ]]; then
            tmp="${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
            tmp=$(format_commit_message "$tmp")
            formatList+="$tmp\n"
        elif [[ $line =~ ^(test\((.*)\)|test):(.*)$ ]]; then
            tmp="${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
            tmp=$(format_commit_message "$tmp")
            testList+="$tmp\n"
        elif [[ $line =~ ^(tests\((.*)\)|tests):(.*)$ ]]; then
            tmp="${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
            tmp=$(format_commit_message "$tmp")
            testList+="$tmp\n"
        elif [[ $line =~ ^(doc\((.*)\)|doc):(.*)$ ]]; then
            tmp="${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
            tmp=$(format_commit_message "$tmp")
            documentationList+="$tmp\n"
        elif [[ $line =~ ^(docs\((.*)\)|docs):(.*)$ ]]; then
            tmp="${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
            tmp=$(format_commit_message "$tmp")
            documentationList+="$tmp\n"
        else 
            tmp=$(format_commit_message "$line")
            otherList+="$tmp\n"
        fi
    done <<< "$changelog"


    # Only add sections if they have any content
    if [ $(echo -e "$featureList" | wc -l) -gt 3 ]; then
        completeChangelog+="\n"
        completeChangelog+=$featureList
    fi

    if [ $(echo -e "$fixList" | wc -l) -gt 3 ]; then
        completeChangelog+="\n"
        completeChangelog+=$fixList
    fi

    if [ $(echo -e "$maintenanceList" | wc -l) -gt 3 ]; then
        completeChangelog+="\n"
        completeChangelog+=$maintenanceList
    fi

    if [ $(echo -e "$buildList" | wc -l) -gt 3 ]; then
        completeChangelog+="\n"
        completeChangelog+=$buildList
    fi

    if [ $(echo -e "$testList" | wc -l) -gt 3 ]; then
        completeChangelog+="\n"
        completeChangelog+=$testList
    fi

    if [ $(echo -e "$refactorList" | wc -l) -gt 3 ]; then
        completeChangelog+="\n"
        completeChangelog+=$refactorList
    fi

    if [ $(echo -e "$documentationList" | wc -l) -gt 3 ]; then
        completeChangelog+="\n"
        completeChangelog+=$documentationList
    fi

    if [ $(echo -e "$otherList" | wc -l) -gt 3 ]; then
        completeChangelog+="\n"
        completeChangelog+=$otherList
    fi

    # unset case insensitive matching
    shopt -u nocasematch
}

normal_changelog() {
    completeChangelog+=$changelog
}

#conventional_commit="yes"
markdown_output="yes"

make_header
if [ -n "${conventional_commit}" -a "${conventional_commit}" == "yes" ]; then
    conventional_commit_changelog
else
    normal_changelog
fi

echo "Made COMMIT_CHANGELOG_MARKDOWN..."

markdownChangelog="$completeChangelog"

markdown_output="no"

make_header
if [ -n "${conventional_commit}" -a "${conventional_commit}" == "yes" ]; then
    conventional_commit_changelog
else
    normal_changelog
fi

echo "Made COMMIT_CHANGELOG..."

# Output collected information
echo "Latest tag: $latest_tag"
echo "Previous tag: $previous_tag"

# Set environment variable for bitrise
envman add --key COMMIT_CHANGELOG --value "$(echo -e $completeChangelog)"
envman add --key COMMIT_CHANGELOG_MARKDOWN --value "$(echo -e $markdownChangelog)"

exit 0