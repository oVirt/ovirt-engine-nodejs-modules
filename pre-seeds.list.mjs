/*
  This file contains definitions for `preseeds`.  They allow referencing an open/unmerged
  github pull request as another source for `package.json` and `yarn.lock` files.  This
  allows a pull request to be able to build properly BEFORE it is merged.

  Each pre-seed source should reference the GitHub project source, specific root
  folder in the the repo where the correct `package.json` and `yarn.lock` files are
  located, and the set of pull requests to access.
  */
export default {
  'ui-extensions': {
    github: {
      owner: 'oVirt',
      repo: 'ovirt-engine-ui-extensions'
    },
    folder: '/',
    pr: [
      70,
      72,
    ]
  },

  'ovirt-web-ui': {
    github: {
      owner: 'oVirt',
      repo: 'ovirt-web-ui'
    },
    folder: '/',
    pr: [

    ]
  },

  'cockpit-ovirt': {
    github: {
      owner: 'oVirt',
      repo: 'cockpit-ovirt'
    },
    folder: '/dashboard',
    pr: [

    ]
  },
}
