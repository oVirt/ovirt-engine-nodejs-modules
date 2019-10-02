#! /bin/bash -e

yarn_global_cache=${GLOBAL_CACHE:-`yarn cache dir`}
yarn_offline_cache=${OFFLINE_CACHE:-`yarn config get yarn-offline-mirror`}

#
# Record every package that has been installed (to global cache populated by `yarn install`)
#
declare -A in_use

for installed_package in $(
    find ${yarn_global_cache} -name '.yarn-metadata.json' -print0 |
    sort -z |
    xargs -0 jq -r '.manifest | [ (.name | gsub("/";"-")), .version ] | join("-")'
); do
    in_use[${installed_package}]="Y"
done

echo "Number of packages installed: ${#in_use[@]}"

#
# For each package archive in the offline cache, check that it has been installed.  If
# it has not been installed, it is no longer needed and is removed.
#
removed=()

for cached_package in $(
  find -L ${yarn_offline_cache} -type f -name '*.tgz' -print0 |
  sort -z |
  xargs -0 basename -s .tgz
); do
    # echo "  ${cached_package} = \"${in_use[$cached_package]}\""

    if [[ -z ${in_use[$cached_package]} ]]; then
      removed+=("${cached_package}")
      rm "${yarn_offline_cache}/${cached_package}.tgz"
    fi
done

echo "Number of cached packages pruned: ${#removed[@]}"
for r in "${removed[@]}"; do
    echo "    $r"
done
