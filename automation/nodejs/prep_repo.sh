#! /bin/bash -ex

if [[ "${REPO_DIR}" == "" || "${REPO_URL}" == "" ]]; then
  exit 10
fi

cd ${REPO_DIR}
git init
git remote add origin ${REPO_URL}
git fetch --no-tags --prune --depth=1 origin ${REPO_REF:-master}:target
git checkout target

date="$(date --utc +%Y%m%d)"
commit="$(git log -1 --pretty=format:%h)"
rename="_${date}git${commit}"

cd ..
mv ${REPO_DIR} ${REPO_DIR}${rename}
