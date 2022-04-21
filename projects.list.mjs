import { fileURLToPath } from 'url'
import { dirname } from 'path'

/*
  This file contains definitons for each project, allowing us to pull a `package.json`
  and associated `yarn.lock` file.

  Each project should reference the core git clone URL, target branch and specific root
  folder in the the repo where the correct `package.json` and `yarn.lock` files are
  located.

  The `preseeds` section allow referencing an open and unmerged github pull request
  as another source for `pacakge.json` and `yarn.lock` files.  This allows a pull
  request to be able to build properly BEFORE it is merged.
 */
export default {
  config: {
    project_root: dirname(fileURLToPath(import.meta.url)),
  },

  projects: {
    'ui-extensions': {
      git_url: 'https://github.com/oVirt/ovirt-engine-ui-extensions.git',
      branch: 'master',
      folder: '/',
    },

    'ovirt-web-ui': {
      git_url: 'https://github.com/oVirt/ovirt-web-ui.git',
      branch: 'master',
      folder: '/',
    },

    'cockpit-ovirt': {
      git_url: 'https://github.com/oVirt/cockpit-ovirt.git',
      branch: 'master',
      folder: '/dashboard',
    },
  },

  preseeds: {
    'ui-extensions': {
      github: {
        owner: 'oVirt',
        repo: 'ovirt-engine-ui-extensions'
      },
      folder: '/',
      pr: [
        54,
      ]
    },

    'ovirt-web-ui': {
      github: {
        owner: 'oVirt',
        repo: 'ovirt-web-ui'
      },
      folder: '/',
      pr: [
        1549,
        1564,
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
  },
}
