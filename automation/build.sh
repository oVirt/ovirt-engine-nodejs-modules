#!/bin/sh -ex

DISTVER="$(rpm --eval "%dist"|cut -c2-3)"
PACKAGER=""
if [[ "${DISTVER}" == "el" ]]; then
    PACKAGER=yum
else
    PACKAGER=dnf
fi


# Make sure the artifacts directory is empty:
artifacts_dir="${PWD}/exported-artifacts"
rm -rf "${artifacts_dir}" && mkdir -p "${artifacts_dir}"

# Node.js is provided by the "ovirt-engine-nodejs" package:
PATH="/usr/share/ovirt-engine-nodejs/bin:${PATH}"

# Yarn is provided by the "ovirt-engine-yarn" package:
PATH="/usr/share/ovirt-engine-yarn/bin:${PATH}"

# Make sure we remember to update the version and/or release:
./automation/check-version-release.sh

# The "build.packages.force" file contains BuildRequires packages
# to be installed using their latest version.
# Force CI to get the latest version of these packages:
dependencies="$(sed -e '/^[ \t]*$/d' -e '/^#/d' automation/build.packages.force)"
${PACKAGER} clean metadata
${PACKAGER} -y install ${dependencies}

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


# Populate offline cache for the last build of this project:
nodejs_modules_cache="/usr/share/ovirt-engine-nodejs-modules/yarn-offline-cache"
if [[ -d "${nodejs_modules_cache}" ]]; then
  find "${nodejs_modules_cache}" -name "*.tgz" -exec mv {} "${yarn_offline_cache_dir}" \;
  echo "Prefilled the offline cache from $(rpm -q ovirt-engine-nodejs-modules)"
fi


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
    cp --backup=t "package.json" "${projects_files_dir}/package.json"
    cp --backup=t "yarn.lock" "${projects_files_dir}/yarn.lock"

    # Download JavaScript dependencies using Yarn, this will
    # populate the "node_modules" directory as well as update
    # the offline cache directory:
    yarn install --pure-lockfile

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
    yarn install --pure-lockfile

done

# Clean up intermediate files left behind:
rm -rf "package.json" "yarn.lock" "node_modules"

# Remove the "LICENSES" file before generating a new one:
rm -rf "LICENSES"

# For each source file located in the offline cache directory,
# resolve its license and append it into the "LICENSES" file:
for src_file in `find ${yarn_offline_cache_dir} -type f -name *.tgz | sort`; do

    # Example: 'path-exists-3.0.0'
    src_file_base=`basename ${src_file} | sed 's/\.tgz$//'`

    # Find the corresponding "package.json" file within Yarn's
    # global cache directory:
    src_package_json=`readlink -f \
        $(find ${yarn_global_cache_path}/*${src_file_base}* -type f -name package.json | head -1)` || /bin/true

    if [ -n "$src_package_json" ]; then
        # Parse the license from the "package.json" file:
        src_license=`jq -r '.license' ${src_package_json}`

        # Append license information into the "LICENSES" file:
        printf "${src_file_base}\n  License: ${src_license}\n" >> LICENSES
    fi

done

# Pack the offline cache directory into a tarball:
yarn_offline_cache_tar="${yarn_offline_cache_dir}.tar"
tar -cf "${yarn_offline_cache_tar}" "${yarn_offline_cache_dir}"

# Expose the offline cache directory listing in the artifacts
# directory (used to verify bundled JavaScript dependencies):
ls -1 "${yarn_offline_cache_dir}" > "${artifacts_dir}/bundled_dependencies.list"

# Expose the "projects_files" directory content as a tarball
# in the artifacts directory:
tar -cf "${artifacts_dir}/projects_files.tar" "${projects_files_dir}"

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
