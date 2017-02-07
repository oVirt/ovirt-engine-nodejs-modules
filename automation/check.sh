#!/bin/sh -ex

# The following loop is taken from "build.sh" - the goal is to validate
# that all project specific files specified in the "projects.list" file
# are available for the subsequent RPM build:
sed -e '/^[ \t]*$/d' -e '/^#/d' projects.list | while read -r line; do

    package_json_url="${line/\{FILE\}/package.json}"
    yarn_lock_url="${line/\{FILE\}/yarn.lock}"

    wget -O "package.json" "${package_json_url}"
    wget -O "yarn.lock" "${yarn_lock_url}"

done
