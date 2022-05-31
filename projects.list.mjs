import { fileURLToPath } from 'url'
import { dirname } from 'path'

/*
  This file contains definitions for each project, allowing us to pull a `package.json`
  and associated `yarn.lock` file.

  Each project should reference the core git clone URL, target branch and specific root
  folder in the the repository where the correct `package.json` and `yarn.lock` files are
  located.
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
}
