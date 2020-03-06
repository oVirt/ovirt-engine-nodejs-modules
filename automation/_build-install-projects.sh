#! /bin/bash -ex

projects_files_dir=${PROJECT_FILES:-""}

GITHUB='githubusercontent.*/.+?/(.+?)/(.+?)/\{FILE\}'
GERRIT='gerrit.*p=(.+?).git.*hb=(refs/heads/)?(.*)$'

#
# The "projects.list" file contains URLs, each one referencing
# a "package.json" file and the associated "yarn.lock" file for
# the given project.
#
# When reading the "projects.list" file, make sure to remove
# blank lines as well as lines starting with the "#" character:
#
sed -e '/^[ \t]*$/d' -e '/^#/d' projects.list | while read -r line; do

    # Clean up intermediate files:
    rm -rf "package.json" "yarn.lock" "node_modules"

    # Resolve file URLs, substituting the "{FILE}" placeholder
    # with specific file name:
    package_json_url="${line/\{FILE\}/package.json}"
    yarn_lock_url="${line/\{FILE\}/yarn.lock}"

    # Download the "package.json" file:
    wget --progress=dot -O "package.json" "${package_json_url}"

    # Download the "yarn.lock" file:
    wget --progress=dot -O "yarn.lock" "${yarn_lock_url}"

    # Copy downloaded files into the "projects_files" directory
    if [[ -n "${projects_files_dir}" ]]; then
        DIR=""
        [[ $line =~ $GITHUB ]] && DIR=${BASH_REMATCH[1]}_${BASH_REMATCH[2]}
        [[ $line =~ $GERRIT ]] && DIR=${BASH_REMATCH[1]}_${BASH_REMATCH[3]/HEAD/master}
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
