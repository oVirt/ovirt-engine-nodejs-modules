#! /bin/bash -e

yarn_global_cache=${GLOBAL_CACHE:-`yarn cache dir`}

# Remove the "LICENSES" file before generating a new one:
rm -rf "LICENSES"

#
# For each package located in the global cache directory (where yarn caches all packages
# that have been installed across all `yarn install`s), resolve its license and append
# it into the "LICENSES" file:
#
find ${yarn_global_cache} -name '.yarn-metadata.json' -print0 |
sort -z |
xargs -0 jq -r '.manifest | [ .name, .version, .license."type"? // .license ] | join(",")' |
while IFS=',' read -ra package_info; do
    if [[ ! -z "${package_info[0]}" ]]; then
        package_info="$(
          printf "${package_info[0]}-${package_info[1]}\n  License: ${package_info[2]}\n"
        )"
        echo -e "${package_info}" | tee -a "LICENSES"
    fi
done
