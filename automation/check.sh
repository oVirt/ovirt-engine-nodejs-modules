#!/bin/bash -e

# Make sure we remember to update the version and/or release:
./automation/check-version-release.sh

# Make sure we only have 1 instance of yarn
[[ $(ls -1 yarn-*.js | wc -l) -ne 1 ]] && { echo "Error: multiple yarn binaries present"; exit 5; }

# Make sure the rpmspec file is valid (specifically that the changelog dates won't kill the build)
SPECLINT=$(rpmlint ovirt-engine-nodejs-modules.spec 2>&1) || linterror=$?
if [[ $linterror -ne 0 ]]; then
    echo "Error or warning in 'ovirt-engine-nodejs-modules.spec':"
    echo "$SPECLINT"
    exit 6
fi

# The following loop is taken from "build.sh" - the goal is to validate
# that all project specific files specified in the "projects.list" file
# are available for the subsequent RPM build:
sed -e '/^[ \t]*$/d' -e '/^#/d' projects.list | while read -r line; do
    echo "Check ${line}"

    package_json_url="${line/\{FILE\}/package.json}"
    yarn_lock_url="${line/\{FILE\}/yarn.lock}"

    wget -qO "package.json" "${package_json_url}" || exit 1
    echo "  project name: $(jq '.name' package.json)"
    rm package.json

    wget -qO "yarn.lock" "${yarn_lock_url}" || exit 2
    rm yarn.lock
done

# Check if all pre-seeds are still valid - PR needs to be opened and not merged or abandoned
Errors=()
while read -r dname; do
    echo "Check ${dname}"
    pr=$(echo ${dname/#pre-seed\/} | cut -d_ -f2)
    if [[ "${pr:0:1}" =~ ^I ]]; then
        echo "  gerrit Change-Id: $pr"
        status=$(wget -qO - "http://gerrit.ovirt.org/changes/?q=${pr}" | sed -E '1d; /^\[|^\]/d' | jq -r .status)
        if [[ -z "$status" || "$status" = "MERGED" || "$status" = "ABANDONED" ]]; then
            # echo "  Error: You need to fix ${dname}. Invalid status of ${pr}: ${status}"
            Errors+=("Please fix ${dname}, invalid status of ${pr}: ${status}")
        fi
    elif [[ "${pr:0:1}" =~ ^[0-9] ]]; then
        echo "  github PR: $pr"
        state=$(wget -qO - https://api.github.com/repos/oVirt/ovirt-web-ui/pulls/${pr} | jq -r .state)
        if [[ ! "$state" = "open" ]]; then
            # echo "  Error: You need to fix ${dname}. Invalid state of ${pr}: ${state}"
            Errors+=("Please fix ${dname}, invalid state of ${pr}: ${state}")
        fi
    else
        echo "Invalid pre-seed directory ${dname}"
        exit 4
    fi
done < <(
    find pre-seed -mindepth 1 -maxdepth 1 -type d
)

if [[ ${#Errors[@]} -gt 0 ]]; then
    echo ""
    echo "Some pre-seeds have issues:"
    for e in "${Errors[@]}"; do
        echo "  - $e"
    done
    exit 3
fi
