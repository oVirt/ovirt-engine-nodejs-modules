#! /bin/bash -e

# Setup the working directory and make sure it is empty
export WORKING_ROOT="${PWD}/_working_"
[[ -d "$WORKING_ROOT" ]] && rm -rf "$WORKING_ROOT"
mkdir -p "$WORKING_ROOT"

# Run the project verifications
./automation/nodejs/verify_projects.mjs || error_project=$?

# Run the pre-seed verifications
./automation/nodejs/verify_pre-seeds.mjs || error_preseed=$?

# Errors detected?
if [[ $error_project -ne 0 || $error_preseed -ne 0 ]]; then
    exit 10
fi

# Move the 'install from directory' directories to the right place
if [[ -d "${PROJECTS_FILES}" ]]; then
    find "${WORKING_ROOT}" -mindepth 1 -maxdepth 1 -type d -name "*.git.*" \
        -exec mv {} "${PROJECTS_FILES}" \;
fi
