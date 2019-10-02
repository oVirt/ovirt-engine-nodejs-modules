#!/bin/sh -e

if ! git show -- *.spec | \
    grep '^+\(Version:\|Release:\)'
then
    echo "Package version or release must be updated"
    exit 1
fi
