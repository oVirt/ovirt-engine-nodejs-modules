#!/bin/sh -ex

# Use this script to set up Node.js environment and populate
# the "./node_modules" directory when building your project.
#
# See the README file for more details.

# Node.js is provided by the "ovirt-engine-nodejs" package:
export PATH="/usr/share/ovirt-engine-nodejs/bin:${PATH}"

# Yarn is provided by the "ovirt-engine-yarn" package:
export PATH="/usr/share/ovirt-engine-yarn/bin:${PATH}"

# Tell Yarn to use the offline cache directory provided by
# the "ovirt-engine-nodejs-modules" package:
yarn config set yarn-offline-mirror "/usr/share/ovirt-engine-nodejs-modules/yarn-offline-cache"

# Populate the "./node_modules" directory using Yarn:
yarn install --offline --pure-lockfile

# JavaScript modules put their executables (if any) into
# the "./node_modules/.bin" directory, make sure it's on
# the PATH:
export PATH="./node_modules/.bin:${PATH}"
