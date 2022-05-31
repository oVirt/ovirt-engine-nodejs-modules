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

# Point to "our" Yarn (and since the js has an initial hashbang, it can run itself)
export YARN=$(find "${PWD}" -maxdepth 1 -name 'yarn-*.js')
chmod +x "$YARN"
yarn () {
    "$YARN" $*
}
export -f yarn

# Setup node_modules for automation/nodejs
pushd ./automation/nodejs; yarn install; popd

# Validate the projects (git repo ok, necessary files can be found) AND the
# pre-seeds (PR is open and not merged/closed/abandoned)
./automation/_build-setup-verify.sh || error_verify=$?
if [[ $error_verify -eq 0 ]]; then
    echo "Ok!"
else
    echo "Fail!!"
    exit 7
fi
