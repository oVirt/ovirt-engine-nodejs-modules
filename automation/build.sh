#!/bin/bash -ex

# Make sure the artifacts directory is empty:
artifacts_dir="${PWD}/exported-artifacts"
rm -rf "${artifacts_dir}" && mkdir -p "${artifacts_dir}"

# If the build should check commits for version updates (e.g. if building a PR branch):
if [[ "${CHECK_VERSION:-no}" == "yes" ]] ; then
    ./automation/check-version-release.sh
fi

which node
node --version

# Point to "our" Yarn (and since the js has an initial hashbang, it can run itself)
export YARN=$(find "${PWD}" -maxdepth 1 -name 'yarn-*.js')
chmod +x "$YARN"
yarn () {
    "$YARN" $*
}
export -f yarn
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

# Since wget and yarn respect the normal http_proxy, https_proxy and no_proxy
# env vars, make sure we don't use any proxy on this domains we query
export no_proxy=localhost,127.0.0.1,registry.yarnpkg.com,gerrit.ovirt.org,raw.githubusercontent.com

# Make yarn network requests more forgiving
yarn config set network-timeout 90000

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

# Download/install yarn dependencies merged to the projects
PROJECT_FILES="${projects_files_dir}" ./automation/_build-install-projects.sh

# Download/install yarn dependencies on unmerged patches/PRs
PROJECT_FILES="${projects_files_dir}" ./automation/_build-install-pre-seeds.sh

# Clean up intermediate files
rm -rf "package.json" "yarn.lock" "node_modules"

#
# Report some yarn request statistics
#
echo "yarn install count: $(ls -1 *.har | wc -l)" | tee yarn_network_stats.txt
echo "yarn request count: $(jq -s '[.[].log.entries | length] | add' *.har)" | tee -a yarn_network_stats.txt
echo "yarn fetches for packages not included in offline pre-fill:" | tee -a yarn_network_stats.txt
jq '.log.entries[].request.url as $url | select($url | contains("registry")) | $url' *.har | sort | tee -a yarn_network_stats.txt
rm *.har

# Remove offline cache modules that are no longer being used
GLOBAL_CACHE="${yarn_global_cache_dir}" OFFLINE_CACHE="${yarn_offline_cache_dir}" ./automation/_build-prune-cache.sh

# Build the "LICENSES" file, one entry per package cached by this module
GLOBAL_CACHE="${yarn_global_cache_dir}" ./automation/_build-licenses.sh

# Expose the "projects_files" and "pre-seed" directory contents as a tarball
# in the artifacts directory:
tar -cf projects_files.tar "${projects_files_dir}"

# Expose the offline cache directory listing in the artifacts
# directory (used to verify bundled JavaScript dependencies):
ls -1 "${yarn_offline_cache_dir}" > yarn_offline_cache.list

# Pack the source tarballs
yarn_offline_cache_tar="yarn-offline-cache.tar"
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


if [[ "${1:-foo}" == "copr" ]] ; then
    # Build the source package:
    rpmbuild \
        -bs \
        --define="_sourcedir ${PWD}" \
        --define="_srcrpmdir ${artifacts_dir}" \
        --define="_rpmdir ${artifacts_dir}" \
        "ovirt-engine-nodejs-modules.spec"
else
    # Build the source and binary packages:
    rpmbuild \
        -ba \
        --define="_sourcedir ${PWD}" \
        --define="_srcrpmdir ${artifacts_dir}" \
        --define="_rpmdir ${artifacts_dir}" \
        "ovirt-engine-nodejs-modules.spec"
fi
