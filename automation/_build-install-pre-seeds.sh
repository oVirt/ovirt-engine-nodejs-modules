#! /bin/bash -ex

projects_files_dir=${PROJECT_FILES:-""}

#
# The "pre-seed" directory contains subdirectories each containing
# a "package.json" file and the associated "yarn.lock" file for
# the given pre-seed.
#
find pre-seed -mindepth 1 -maxdepth 1 -type d | while read -r dname; do

    # Clean up intermediate files:
    rm -rf "package.json" "yarn.lock" "node_modules"

    echo "$dname"
    ls -la "$dname"
    cp "$dname/package.json" .
    cp "$dname/yarn.lock" .

    # Copy package.json, yarn.lock files into the "projects_files" directory
    if [[ -n "${projects_files_dir}" ]]; then
        DIR=$(basename "$dname")
        [[ ! -e "$DIR" ]] && mkdir -p "${projects_files_dir}/$DIR"
        cp --backup=t package.json yarn.lock "${projects_files_dir}/$DIR"
    fi

    # Download JavaScript dependencies using Yarn, this will
    # populate the "node_modules" directory as well as update
    # the offline cache directory:
    yarn install --pure-lockfile  --har ||
        yarn install --pure-lockfile  --har ||
            yarn install --pure-lockfile  --har

done
