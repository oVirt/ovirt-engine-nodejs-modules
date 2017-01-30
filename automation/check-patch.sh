#!/bin/sh -ex

# The "projects.list" file contains URLs, each one referencing
# a "package.json" file and the associated "yarn.lock" file (if
# one exists) for the given project.
# When reading the "projects.list" file, make sure to remove
# blank lines as well as lines starting with the "#" character:
sed -e '/^[ \t]*$/d' -e '/^#/d' projects.list | while read -r line; do

    # Clean up intermediate files:
    rm -rf package.json yarn.lock node_modules

    # Resolve file URLs, substituting the "{FILE}" placeholder
    # with specific file name:
    package_json_url="${line/\{FILE\}/package.json}"
    yarn_lock_url="${line/\{FILE\}/yarn.lock}"

    # Download the "package.json" file (required):
    wget -O "package.json" "${package_json_url}"

    # Download the "yarn.lock" file (optional):
    wget -O "yarn.lock" "${yarn_lock_url}" || true

done
