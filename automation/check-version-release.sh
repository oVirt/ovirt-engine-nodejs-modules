#!/bin/bash -ex

if ! git show ${CHECK_RANGE:-HEAD} -- *.spec | \
    grep '^+\(Version:\|Release:\)'
then
    echo "Package version or release must be updated"
    exit 1
fi
