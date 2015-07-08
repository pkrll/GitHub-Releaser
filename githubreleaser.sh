#!/bin/bash
###############################################################
# Shellscript:	gitrelease.sh - Automatically creates a release
# Version    :  1.0
# Author     :	Ardalan Samimi ()
# Date       :	08-07-15
###############################################################
# Description
#
# RELEASE NOTES
# 08-07-15      None
###############################################################


# GLOBALS
UPDATE_TYPE=0
TAG_NAME=0
NEW_VERSION=0
#COMPOSER_JSON="composer.json"

USERNAME="" #CHANGE THIS
TOKEN="" #CHANGE THIS
URL=https://api.github.com/repos/user/repo/releases # CHANGE THIS

#######################################
# Main function
# Globals:
#   UPDATE_TYPE
#   TAG_NAME
#   NEW_VERSION
# Arguments:
#   None
# Returns:
#   None
#######################################
function main () {
    MESSAGE=0
    input "Would you like to create a new release? (y/n)" MESSAGE
    # User is king
    if [ $MESSAGE != "y" ]; then
        exit
    fi
    # Retrieve the latest releases tag name
    getTag TAG_NAME
    if [ -z "$TAG_NAME" ]; then
        input "There aren't any releases yet for your project. Type in the tag (for example 1.0.0)" NEW_VERSION
    else
        input "What kind of update is this: major, minor or patch?" UPDATE_TYPE
        #Increment the version.
        incrementVersion $TAG_NAME NEW_VERSION
    fi

    NEW_VERSION="v"$NEW_VERSION
    echo "New tag set to "$NEW_VERSION
    echo "Creating new release"
    input "Describe the release (using one word if you can...): " DESCRIPTION

    data="$( printf '{"tag_name": "%s", "target_commitish": "master", "name": "%s", "body": "%s", "draft": false, "prerelease": false}' "$NEW_VERSION" "$NEW_VERSION" "$DESCRIPTION" )"

    # Change user and repo to your user name and the repo you want to create releases for
    curl --user $USERNAME -X POST --data "$data" URL
}

function incrementVersion () {
    local tmp len
    explode ${1} tmp
    len=${#tmp[@]}

    if [ $UPDATE_TYPE == "minor" ]; then
        if [ $len == 3 ]; then
            (( len -= 2 ))
        fi
    elif [ $UPDATE_TYPE == "major" ]; then
        len=0
    else
        (( len -= 1 ))
    fi

    (( tmp[$len] += 1 ))
    implode tmp . ${tmp[@]}
    local ${2} && upvar ${2} ${tmp}
}

function explode () {
    IFS='.' read -a array <<< "$1"
    local "$2" && upvar $2 ${array[@]}
}

function implode () {
    value=$(IFS="$2"; shift; shift; echo "$*";)
    local "$1" && upvar $1 $value
}

#######################################
# Retrieve the value of a JSON key from
# the JSON file passed as argument.
# Inspired, but really mostly copied by
# http://tuxmark.blogspot.se/2013/10/bash-regex-to-get-json-value.html
# Globals:
#   VERSION_CUR
# Arguments:
#   String JSON file
#   String JSON key
# Returns:
#   String
#######################################
function getJSONValue () {
    VERSION_CUR=$(perl -nle 'print $& if m{"'"$2"'"\s*:\s*"\K([^"]*)}' $1)
}

# checkIfFileExists (file)
function fileExists () {
    if [ ! -f $1 ]
        then
        return 1 # 1 = false. Weird.
    else
        return 0 # 0 = true. Really.
    fi
}

#######################################
# Retrieve the releaase tags from the
# users repos.
# Globals:
#   none
# Arguments:
#   String JSON file
#   String JSON key
# Returns:
#   String
#######################################
function getTag () {
    local tmp=$(curl -s https://api.github.com/repos/pkrll/php/releases?access_token=$TOKEN | ./JSON.sh -l | egrep 'tag_name')
    # tmp="[0,'tag_name'] v1.1.0"
    tmp=$(echo $tmp | grep -o -E '[^\v\[][0-9.]+')
    local "$1" && upvar $1 $tmp
}

# Assign variable one scope above the caller.
# Usage: local "$1" && upvar $1 value [value ...]
# Param: $1  Variable name to assign value to
# Param: $*  Value(s) to assign.  If multiple values, an array is
#            assigned, otherwise a single value is assigned.
# NOTE: For assigning multiple variables, use 'upvars'.  Do NOT
#       use multiple 'upvar' calls, since one 'upvar' call might
#       reassign a variable to be used by another 'upvar' call.
# See: http://fvue.nl/wiki/Bash:_Passing_variables_by_reference
upvar() {
    if unset -v "$1"; then           # Unset & validate varname
        if (( $# == 2 )); then
            eval $1=\"\$2\"          # Return single value
        else
            eval $1=\(\"\${@:2}\"\)  # Return array
         fi
    fi
}

function input () {
    read -p "$1 " message
    local "$2" && upvar $2 $message
}


main
