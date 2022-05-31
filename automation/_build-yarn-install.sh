#! /bin/bash -ex

projects_files_dir=${PROJECTS_FILES:-""}

# Setup the working directory and make sure it is empty
WORKING_ROOT="${PWD}/_working_"
[[ -d "$WORKING_ROOT" ]] && rm -rf "$WORKING_ROOT"
mkdir -p "$WORKING_ROOT"

#
# The "projects_files_dir" directory contains subdirectories each containing
# a "package.json" file and the associated "yarn.lock" file for the given
# project or pre-seed.
#
for project in $(
    find "${projects_files_dir}" -mindepth 1 -maxdepth 1 -type d |
    sort
); do

    # Setup the work
    echo "$project"
    cp "$project/package.json" "${WORKING_ROOT}"
    cp "$project/yarn.lock" "${WORKING_ROOT}"
    pushd "${WORKING_ROOT}"

    # Download JavaScript dependencies using Yarn, this will
    # populate the "node_modules" directory as well as update
    # the offline cache directory:
    yarn install --pure-lockfile  --har ||
        yarn install --pure-lockfile  --har ||
            yarn install --pure-lockfile  --har

    # All done with the work
    rm -rf node_modules package.json yarn.lock
    popd

done

mv "${WORKING_ROOT}"/*.har .
