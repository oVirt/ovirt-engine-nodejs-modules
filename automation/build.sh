#!/bin/bash -ex

# Make sure the artifacts directory is empty:
artifacts_dir="${PWD}/exported-artifacts"
rm -rf "${artifacts_dir}" && mkdir -p "${artifacts_dir}"

# Make sure we remember to update the version and/or release:
./automation/check-version-release.sh

# Node.js is provided by the "ovirt-engine-nodejs" package:
# not needed on fc30/el8, remove when dropping fc29&el7
PATH="/usr/share/ovirt-engine-nodejs/bin:${PATH}"
which node
node --version

# Point to "our" Yarn (and since the js has an initial hashbang, it can run itself)
YARN=$(find "${PWD}" -maxdepth 1 -name 'yarn-*.js')
chmod +x "$YARN"
yarn () {
    "$YARN" $*
}
export yarn
yarn --version

# Create the "projects_files" directory to collect all project
# specific files used when building this package:
projects_files_dir="projects_files"
rm -rf "${projects_files_dir}" && mkdir -p "${projects_files_dir}"

# When Yarn downloads dependencies, utilize the "offline mirror"
# feature that puts .tar.gz sources of all dependencies into the
# local "yarn-offline-cache" directory:
yarn_offline_cache_dir="yarn-offline-cache"
yarn config set yarn-offline-mirror "${PWD}/${yarn_offline_cache_dir}"

# Clean up the offline cache directory:
rm -rf "${yarn_offline_cache_dir}"

# Customize the global cache directory used by Yarn (this is the
# actual cache, not to confuse with the "offline mirror" feature):
yarn_global_cache_dir="yarn-global-cache"
yarn config set cache-folder "${PWD}/${yarn_global_cache_dir}"
yarn_global_cache_path="$(yarn cache dir)"

# Clean up the global cache directory:
rm -rf "${yarn_global_cache_dir}"

# Populate offline cache from the last build of this project:
nodejs_modules_cache="/usr/share/ovirt-engine-nodejs-modules/yarn-offline-cache"
if [[ -d "${nodejs_modules_cache}" ]]; then
    find "${nodejs_modules_cache}" -name "*.tgz" -exec ln -s {} "${yarn_offline_cache_dir}"/ \;
    echo "Prefilled the offline cache from $(rpm -q ovirt-engine-nodejs-modules)"
fi

GITHUB='githubusercontent.*/.+?/(.+?)/(.+?)/\{FILE\}'
GERRIT='gerrit.*p=(.+?).git.*hb=(refs/heads/)?(.*)$'
# The "projects.list" file contains URLs, each one referencing
# a "package.json" file and the associated "yarn.lock" file for
# the given project.
# When reading the "projects.list" file, make sure to remove
# blank lines as well as lines starting with the "#" character:
sed -e '/^[ \t]*$/d' -e '/^#/d' projects.list | while read -r line; do

    # Clean up intermediate files:
    rm -rf "package.json" "yarn.lock" "node_modules"

    # Resolve file URLs, substituting the "{FILE}" placeholder
    # with specific file name:
    package_json_url="${line/\{FILE\}/package.json}"
    yarn_lock_url="${line/\{FILE\}/yarn.lock}"

    # Download the "package.json" file:
    wget -O "package.json" "${package_json_url}"

    # Download the "yarn.lock" file:
    wget -O "yarn.lock" "${yarn_lock_url}"

    # Copy downloaded files into the "projects_files" directory,
    # use the "backup" argument to prevent over-writing the file
    # if it exists:
    DIR=''
    [[ $line =~ $GITHUB ]] && DIR=${BASH_REMATCH[1]}_${BASH_REMATCH[2]}
    [[ $line =~ $GERRIT ]] && DIR=${BASH_REMATCH[1]}_${BASH_REMATCH[3]/HEAD/master}
    [[ $DIR != '' ]] && mkdir "${projects_files_dir}/$DIR"
    cp --backup=t package.json yarn.lock "${projects_files_dir}/$DIR"

    # Download JavaScript dependencies using Yarn, this will
    # populate the "node_modules" directory as well as update
    # the offline cache directory:
    yarn install --pure-lockfile  --har

done

# The "pre-seed" directory contains subdirectories each containing
# a "package.json" file and the associated "yarn.lock" file for
# the given pre-seed.
find pre-seed -mindepth 1 -maxdepth 1 -type d | while read -r dname; do

    # Clean up intermediate files:
    rm -rf "package.json" "yarn.lock" "node_modules"

    echo "$dname"
    ls -la "$dname"
    cp "$dname/package.json" .
    cp "$dname/yarn.lock" .

    # Download JavaScript dependencies using Yarn, this will
    # populate the "node_modules" directory as well as update
    # the offline cache directory:
    yarn install --pure-lockfile --har

done

rm -rf "package.json" "yarn.lock" "node_modules"

#
# Report some yarn request statistics
#
echo "yarn install count: $(ls -1 *.har | wc -l)" | tee yarn_network_stats.txt
echo "yarn request count: $(jq -s '[.[].log.entries | length] | add' *.har)" | tee -a yarn_network_stats.txt
echo "yarn fetches for packages not included in offline pre-fill:" $(jq '.log.entries[].request.url as $url | select($url | contains("registry")) | $url' *.har | sort) | tee -a yarn_network_stats.txt
rm *.har

# Remove offline cache modules that are no longer being used
GLOBAL_CACHE="${yarn_global_cache_dir}" OFFLINE_CACHE="${yarn_offline_cache_dir}" ./automation/_build-prune-cache.sh

# Build the "LICENSES" file, one entry per package cached by this module
GLOBAL_CACHE="${yarn_global_cache_dir}" ./automation/_build-licenses.sh

# Expose the "projects_files" and "pre-seed" directory contents as a tarball
# in the artifacts directory:
tar -cf projects_files.tar "${projects_files_dir}" "pre-seed"

# Expose the offline cache directory listing in the artifacts
# directory (used to verify bundled JavaScript dependencies):
ls -1 "${yarn_offline_cache_dir}" > yarn_offline_cache.list

# Pack the source tarballs
yarn_offline_cache_tar="${yarn_offline_cache_dir}.tar"
tar --dereference -cf "${yarn_offline_cache_tar}" "${yarn_offline_cache_dir}"

tar cf sources.tar \
    setup-env.sh.in \
    yarn-*.js \
    LICENSES \
    LICENSE-yarn \
    projects_files.tar \
    yarn_network_stats.txt \
    yarn_offline_cache.list

# Collect artifacts
mv projects_files.tar \
    yarn_network_stats.txt \
    yarn_offline_cache.list \
    "${artifacts_dir}"

# Build the source and binary packages:
rpmbuild \
    -ba \
    --define="_offline_cache_tar ${yarn_offline_cache_tar}" \
    --define="_yarn $(basename ${YARN})" \
    --define="_sourcedir ${PWD}" \
    --define="_srcrpmdir ${artifacts_dir}" \
    --define="_rpmdir ${artifacts_dir}" \
    "ovirt-engine-nodejs-modules.spec"
