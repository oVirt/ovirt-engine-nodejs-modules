#!/bin/bash -ex

if ! git show $1 -- *.spec | \
    grep '^+\(Version:\|Release:\)'
then
    echo "Package version or release must be updated"
    exit 1
fi
