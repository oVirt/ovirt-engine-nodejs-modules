#!/bin/sh -ex

# Make sure the artifacts directory is empty:
artifacts_dir="${PWD}/exported-artifacts"
rm -rf "${artifacts_dir}" && mkdir -p "${artifacts_dir}"

# Node.js is provided by the "ovirt-engine-nodejs" package:
PATH="/usr/share/ovirt-engine-nodejs/bin:${PATH}"

# Yarn is provided by the "ovirt-engine-yarn" package:
PATH="/usr/share/ovirt-engine-yarn/bin:${PATH}"

# Make sure we remembered to update the version and/or release
if ! git show -- *.spec | \
    grep '^+\(Version:\|Release:\)'
then
    echo "Package version or release must be updated"
    exit 1
fi

# When Yarn downloads dependencies, utilize the "offline mirror"
# feature that puts .tar.gz sources of all dependencies into the
# local "yarn-offline-cache" directory:
yarn_offline_cache_dir="yarn-offline-cache"
yarn config set yarn-offline-mirror "${PWD}/${yarn_offline_cache_dir}"

# Clean up the offline cache directory:
rm -rf ${yarn_offline_cache_dir}

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

    # Transform offline entries to online ones. Yarn won't connect for offline entries
    sed -i '/resolved "https:\/\//! s#\([ ]*\)resolved \(.*\)-\([0-9]\+\.[0-9]\+\.[0-9]\+.*\)#\1resolved "https://registry.yarnpkg.com/\2/-/\2-\3"#g' yarn.lock

    # Download JavaScript dependencies using Yarn, this will
    # populate the "node_modules" directory as well as update
    # the offline cache directory:
    yarn install

done

# For each source file located in the offline cache directory,
# append its license information into the "LICENSES" file:
for src_file in `find ${yarn_offline_cache_dir} -type f -name *.tgz | sort`; do

    # Example: 'path-exists-3.0.0'
    src_file_base=`basename ${src_file} | sed 's/\.tgz$//'`

    # Example: 'path-exists'
    js_pkg_name=`echo ${src_file_base} | grep -P -o '^[^0-9]+' | sed 's/-$//'`

    # Example: '3.0.0'
    js_pkg_version=`echo "${src_file_base/${js_pkg_name}/}" | sed 's/^-//'`

    # Resolve the license name using Yarn:
    js_pkg_license=`yarn info ${js_pkg_name}@${js_pkg_version} license | sed -n 2p`

    # Append license information into the "LICENSES" file:
    printf "${js_pkg_name}@${js_pkg_version}\n  License: ${js_pkg_license}\n" >> LICENSES

done

# Pack the offline cache directory into a tarball:
yarn_offline_cache_tar="${yarn_offline_cache_dir}.tar"
tar -cf "${yarn_offline_cache_tar}" "${yarn_offline_cache_dir}"

# The name of the package:
name="ovirt-engine-nodejs-modules"

# Build the source and binary packages:
rpmbuild \
    -ba \
    --define "_tar ${yarn_offline_cache_tar}" \
    --define="_sourcedir ${PWD}" \
    --define="_srcrpmdir ${artifacts_dir}" \
    --define="_rpmdir ${artifacts_dir}" \
    "${name}.spec"
