Name: ovirt-engine-nodejs-modules
Version: 2.0.8
Release: 1%{?dist}
Summary: Node.js modules required to build oVirt JavaScript applications
Group: Virtualization/Management
License: Multiple
URL: http://ovirt.org
Source0: %{?_tar}
Source1: LICENSES
Source2: LICENSE-yarn
Source3: setup-env.sh
Source4: yarn-1.17.3.js

BuildArch: noarch

# to be replaced in el8
Requires: ovirt-engine-nodejs

# for existing packages requiring yarn we used to package separately
Provides: ovirt-engine-yarn

%description
Node.js modules required to build oVirt JavaScript applications.

%prep
# Copy additional files to build directory:
cp %{SOURCE1} %{SOURCE2} %{SOURCE3} %{SOURCE4} .

%install
%define dest %{buildroot}%{_datadir}/%{name}

# Create the destination directory in build root:
mkdir -p %{dest}
mkdir -p %{dest}/bin

# Extract the offline cache tarball:
tar -xf %{SOURCE0} -C %{dest}

# Copy additional (non license) files to build root:
cp %{SOURCE3} %{dest}

# install yarn-X.Y.Z.js in bin/ as normal executable
install -m 555 %{SOURCE4} %{dest}/bin/yarn

%files
%license LICENSES
%license LICENSE-yarn
%{_datadir}/%{name}

%changelog
* Mon Sep 19 2019 Bohdan Iakymets <biakymet@redhat.com> - 2.0.8-1
- updated pre-seed for ovirt-web-ui
  Updated: https://github.com/oVirt/ovirt-web-ui/pull/1117
  Removed: https://gerrit.ovirt.org/#/c/102989/

* Mon Sep 16 2019 Scott J Dickerson <sdickers@redhat.com> - 2.0.7-1
- pre-seed for ovirt-engine-ui-extensions
  Add: https://gerrit.ovirt.org/102850

* Tue Sep 10 2019 Ondra Machacek <omachace@redhat.com> - 2.0.6-1
- pre-seed for ovirt-engine-api-explorer

* Thu Sep 10 2019 Scott J Dickerson <sdickers@redhat.com> - 2.0.5-1
- install yarn-*.js as an executable to avoid using an alias/function in setup-env.sh

* Tue Sep 10 2019 Bohdan Iakymets <biakymet@redhat.com> - 2.0.4-1
- update pre-seeds for ovirt-web-ui
   Add: https://github.com/oVirt/ovirt-web-ui/pull/1117
   Remove: ovirt-web-ui_1048

* Tue Sep 03 2019 Bohdan Iakymets <biakymet@redhat.com> - 2.0.3-1
- pre-seed for ovirt-web-ui
  PR: https://github.com/oVirt/ovirt-web-ui/pull/1048

* Tue Sep 03 2019 Michal Skrivanek <michal.skrivanek@redhat.com> - 2.0.2-1
- fix yarn location lookup

* Tue Sep 03 2019 Michal Skrivanek <michal.skrivanek@redhat.com> - 2.0.1-1
- pre-seed for https://gerrit.ovirt.org/#/c/103041/

* Fri Aug 30 2019 Michal Skrivanek <michal.skrivanek@redhat.com> - 2.0.0-1
- pull in latest yarn and deliver it through this package

* Fri Aug 30 2019 Michal Skrivanek <michal.skrivanek@redhat.com> - 1.9.5-2
- Removed old pre-seed for cockpit-ovirt

* Fri Aug 30 2019 Michal Skrivanek <michal.skrivanek@redhat.com> - 1.9.5-1
- Change pre-seed dirname structure to project_changeid or project_pr#
- Add checking for PR/ChangeId validity of pre-seeds

* Fri Aug 30 2019 Michal Skrivanek <michal.skrivanek@redhat.com> - 1.9.4-5
- Removed old (all) pre-seeds for ovirt-cockpit
- Remove obsolete branches from projects.list
- Add back ovirt-engine-api-explorer, it's still alive

* Wed Aug 28 2019 Scott J Dickerson <sdickers@redhat.com> - 1.9.4-4
- Removed old pre-seeds for ovirt-engine-ui-extensions
- Removed old pre-seeds for ovirt-web-ui
- Renamed ovirt-web-ui pre-seed folders to reflect the related PR

* Wed Aug 28 2019 Scott J Dickerson <sdickers@redhat.com> - 1.9.4-3
- fix location of nodejs-modules repo in build.repos of stdci v2

* Tue Aug 27 2019 Michal Skrivanek <michal.skrivanek@redhat.com> - 1.9.4-2
- move automation to stdci v2

* Fri Aug 23 2019 Charles Thao <cthao@redhat.com> - 1.9.4-1
- pre-seed for https://gerrit.ovirt.org/#/c/102081/

* Fri Aug 23 2019 Ido Rosenzwig <irosenzw@redhat.com> - 1.9.3-1
- pre-seed for cockpit-ovirt

* Fri Aug 23 2019 Scott J Dickerson <sdicers@redhat.com> - 1.9.2-1
- Updated project.list for currently valid projects/branches

* Thu Aug 22 2019 Scott J Dickerson <sdickers@redhat.com> - 1.9.1-2
- update pre-seed for https://gerrit.ovirt.org/#/c/102727/

* Wed Aug 21 2019 Charles Thao <cthao@redhat.com> - 1.9.1-1
- pre-seed for ovirt-engine-ui-extensions and ovirt-web-ui
  patch for ui-extensions: https://gerrit.ovirt.org/#/c/102727/
  pr for web-ui: https://github.com/oVirt/ovirt-web-ui/pull/1097

* Wed Aug 21 2019 Michal Skrivanek <michal.skrivanek@redhat.com> - 1.9.0-2
- remove obsolete scripts

* Tue Aug 20 2019 Scott J Dickerson <sdickers@redhat.com> - 1.9.0-1
  Use the previous build of this package to prefill the offline cache
  to reduce the number of http requests needed to just things that are
  new to the nodejs-modules.

* Tue Aug 20 2019 Scott J Dickerson <sdickers@redhat.com> - 1.8.22-1
- pre-seed for ovirt-web-ui
  pr: https://github.com/oVirt/ovirt-web-ui/pull/1093

* Thu Aug 15 2019 Bohdan Iakymets <biakymet@redhat.com> - 1.8.21-1
- pre-seed for ovirt-web-ui

* Mon Aug 12 2019 Ido Rosenzwig <irosenzw@redhat.com> - 1.8.20-1
- pre-seed for cockpit-ovirt

* Wed Aug 7 2019 Scott J Dickerson <sdickers@redhat.com> - 1.8.19-1
- pre-seed for ovirt-engine-ui-extensions
  patch: https://gerrit.ovirt.org/#/c/97032/

* Wed Aug 7 2019 Scott J Dickerson <sdickers@redhat.com> - 1.8.18-1
- pre-seed for ovirt-engine-ui-extensions
  patch: https://gerrit.ovirt.org/#/c/97032/

* Mon Jul 29 2019 Charles Thao <cthao@redhat.com> - 1.8.17-1
- pre-seed for ovirt-engine-ui-extensions

* Mon Jul 22 2019 Charles Thao <cthao@redhat.com> - 1.8.16-1
- pre-seed for ovirt-web-ui

* Wed Jul 17 2019 Scott J Dickerson <sdickers@redhat.com> - 1.8.15-1
- pre-seed for ovirt-web-ui

* Sun Jul 14 2019 Ido Rosenzwig <irosenzw@redhat.com> - 1.8.14-1
- pre-seed for cockpit-ovirt

* Tue Jul 2 2019 Bohdan Iakymets <biakymet@redhat.com> - 1.8.13-1
- pre-seed for ovirt-web-ui

* Tue Jun 25 2019 Scott J Dickerson <sdickers@redhat.com> - 1.8.12-1
- remove pre-seeds from 2018
- pre-seed for:
   - ovirt-web-ui
   - ovirt-engine-ui-extensions

* Mon Jun 24 2019 Parth Dhanjal <dparth@redhat.com> - 1.8.11-1
- pre-seed for cockpit-ovirt

* Mon Jun 17 2019 Ido Rosenzwig <irosenzw@redhat.com> - 1.8.10-1
- pre-seed for cockpit-ovirt

* Wed Apr 24 2019 Ondra Machacek <omachace@redhat.com> - 1.8.9-1
- pre-seed for ovirt-engine-api-explorer

* Mon Mar 4 2019 Scott J Dickerson <sdickers@redhat.com> - 1.8.8-1
- pre-seed for ovirt-web-ui

* Wed Feb 27 2019 Bohdan Iakymets <biakymet@redhat.com> - 1.8.7-1
- pre-seed for ovirt-web-ui

* Fri Feb 1 2019 Greg Sheremeta <gshereme@redhat.com> - 1.8.6-1
- pre-seed for ovirt-web-ui

* Fri Feb 1 2019 Scott J Dickerson <sdickers@redhat.com> - 1.8.5-1
- pre-seed for ovirt-web-ui

* Fri Jan 18 2019 Parth Dhanjal <dparth@redhat.com> - 1.8.4-1
- pre-seed cockpit-ovirt

* Thu Jan 17 2019 Bohdan Iakymets <biakymet@redhat.com> - 1.8.3-1
- pre-seed ovirt-engine-api-explorer

* Tue Dec 18  2018 Scott J Dickerson <sdickers@redhat.com> - 1.8.2-1
- bump for ovirt-web-ui

* Sun Nov 25 2018 Greg Sheremeta <gshereme@redhat.com> - 1.8.1-1
- update ovirt-web-ui

* Wed Oct 10 2018 Greg Sheremeta <gshereme@redhat.com> - 1.8.0-1
- add ovirt-web-ui-1.4 stable branch to projects.list

* Wed Oct 10 2018 Greg Sheremeta <gshereme@redhat.com> - 1.7.4-1
- pre-seed ovirt-web-ui

* Tue Sep 4 2018 Greg Sheremeta <gshereme@redhat.com> - 1.7.3-1
- pre-seed ovirt-web-ui

* Wed Jul 18 2018 Phillip Bailey <phbailey@redhat.com> - 1.7.2-1
- pre-seed cockpit-ovirt

* Fri Jun 29 2018 Scott Dickerson <sdickers@redhat.com> - 1.7.1-1
- pre-seed ovirt-engine-ui-extensions

* Fri Jun 29 2018 Vojtech Szocs <vszocs@redhat.com> - 1.7.0-1
- add ovirt-engine-ui-extensions to projects.list

* Thu Jun 21 2018 Greg Sheremeta <gshereme@redhat.com> - 1.6.0-1
- add switch to disable 'yarn check'
- pre-seed ovirt-js-dependencies

* Wed Jun 13 2018 Greg Sheremeta <gshereme@redhat.com> - 1.5.10-1
- pre-seed ovirt-engine-api-explorer

* Wed Jun 13 2018 Greg Sheremeta <gshereme@redhat.com> - 1.5.9-1
- pre-seed ovirt-js-dependencies

* Fri Jun 8 2018 Greg Sheremeta <gshereme@redhat.com> - 1.5.8-1
- pre-seed ovirt-engine-api-explorer dependencies

* Fri Jun 8 2018 Greg Sheremeta <gshereme@redhat.com> - 1.5.7-1
- pre-seed ovirt-engine-dashboard dependencies

* Thu Jun  7 2018 Greg Sheremeta <gshereme@redhat.com> - 1.5.6-3
- fix case where package.json can't be found on license parse

* Thu Jun  7 2018 Sandro Bonazzola <sbonazzo@redhat.com> - 1.5.6-2
- Rebuilt for Fedora Mass Rebuild

* Thu May 3 2018 Vojtech Szocs <vszocs@redhat.com> - 1.5.6-1
- pre-seed ovirt-engine-dashboard dependencies

* Fri Apr 20 2018 Vojtech Szocs <vszocs@redhat.com> - 1.5.5-1
- pre-seed ovirt-engine-dashboard dependencies

* Fri Apr 6 2018 Marek Libra <mlibra@redhat.com> - 1.5.4-1
- dependencies of ovirt-web-ui changed

* Thu Mar 22 2018 Marek Libra <mlibra@redhat.com> - 1.5.3-1
- dependencies of ovirt-web-ui upgraded

* Thu Mar 22 2018 Marek Libra <mlibra@redhat.com> - 1.5.2-1
- dependencies of ovirt-web-ui updated (added patternfly-react)

* Fri Mar 16 2018 Greg Sheremeta <gshereme@redhat.com> - 1.5.1-1
- pre-seed cockpit-ovirt changes (add moment)

* Fri Mar 16 2018 Greg Sheremeta <gshereme@redhat.com> - 1.5.0-1
- add cockpit-ovirt 4.2 branch to projects.list

* Fri Mar 9 2018 Scott J Dickerson <sdickers@redhat.com> - 1.4.2-1
- pre-seed ovirt-engine-dashboard dependencies (for karma-webpack)

* Thu Feb 15 2018 Scott J Dickerson <sdickers@redhat.com> - 1.4.1-1
- pre-seed ovirt-engine-dashboard dependencies

* Wed Feb 14 2018 Greg Sheremeta <gshereme@redhat.com> - 1.4.0-1
- add ovirt-engine-dashboard-1.2 to projects.list

* Sun Feb 04 2018 Scott J Dickerson <sdickers@redhat.com> - 1.3.2-1
- pre-seed ovirt-engine-dashboard dependencies

* Thu Jan 18 2018 Scott J Dickerson <sdickers@redhat.com> - 1.3.1-1
- pre-seed ovirt-engine-dashboard dependencies

* Sun Jan 14 2018 Greg Sheremeta <gshereme@redhat.com> - 1.3.0-1
- add pre-seed folder to fix chicken-and-egg problem

* Mon Nov 27 2017 Greg Sheremeta <gshereme@redhat.com> - 1.2.2-1
- updated ovirt-engine-dashboard dependencies

* Mon Nov 27 2017 Greg Sheremeta <gshereme@redhat.com> - 1.2.1-1
- updated ovirt-engine-dashboard dependencies

* Wed Sep 27 2017 Juan Hernandez <juan.hernandez@redhat.com> - 1.2.0-1
- Add ovirt-engine-api-explorer to projects.list.

* Tue Aug 15 2017 Marek Libra <mlibra@redhat.com> - 1.1.0-1
- cockpit-ovirt/vdsm (master) subproject removed from projectlist
- all runtime deps of ovirt-web-ui updated to their latests

* Mon Aug 14 2017 Marek Libra <mlibra@redhat.com> - 1.0.19-1
- dependencies of ovirt-web-ui updated

* Tue Aug 1 2017 Greg Sheremeta <gshereme@redhat.com> - 1.0.18-1
- updated ovirt-js-dependencies

* Tue Jun 20 2017 Marek Libra <mlibra@redhat.com> - 1.0.17-1
- ovirt-web-ui package.json updated

* Thu Jun 15 2017 Marek Libra <mlibra@redhat.com> - 1.0.16-1
- Bump the version to pull  ovirt-ui-components 0.2.4

* Mon Jun 5 2017 Greg Sheremeta <gshereme@redhat.com> - 1.0.15-1
- add cockpit-ovirt 4.1 branch to projects.list

* Sat Jun 3 2017 Greg Sheremeta <gshereme@redhat.com> - 1.0.14-1
- bump version for new ovirt-js-dependencies

* Fri Jun 2 2017 Marek Libra <mlibra@redhat.com> - 1.0.13-1
- Bump the version to grab react-router for ovirt-web-ui

* Tue May 30 2017 Ryan Barry <rbarry@redhat.com> - 1.0.12-1
- Bump the version to grab new lockfiles for cockpit-ovirt

* Tue May 16 2017 Greg Sheremeta <gshereme@redhat.com> - 1.0.11-2
- don't hardcode 'v1' in cache path

* Mon May 15 2017 Marek Libra - 1.0.11-1
- dependencies in ovirt-web-ui updated to latest versions (i.e. React)

* Mon May 15 2017 Greg Sheremeta <gshereme@redhat.com> - 1.0.10-4
- remove temporary lockfile editing from setup-env.sh
- add 'v1' to yarn cache patch when building licenses file

* Mon May 15 2017 Greg Sheremeta <gshereme@redhat.com> - 1.0.10-3
- force CI to use latest builds

* Fri May 12 2017 Vojtech Szocs <vszocs@redhat.com> - 1.0.10-2
- Expose bundled JavaScript dependency listing as:
    exported-artifacts/bundled_dependencies.list
- Expose the "projects_files" directory (containing all project
  specific files downloaded during the RPM build) as:
    exported-artifacts/projects_files.tar
- In the setup script, run `yarn check` after `yarn install` to
  ensure consistency between package.json vs. yarn.lock files.

* Fri May 12 2017 Marek Libra - 1.0.10-1
- ovirt-ui-components 0.2.2 released as referenced from ovirt-web-ui

* Wed Apr 19 2017 Marek Libra - 1.0.9-1
- add prop-types as referenced from ovirt-web-ui

* Tue Apr 18 2017 Vojtech Szocs <vszocs@redhat.com> - 1.0.8-1
- bump to pick up jquery-ui-dist coming from ovirt-js-dependencies

* Tue Mar 28 2017 Marek Libra - 1.0.7-1
- ovirt-ui-components 0.2.1 released as referenced from ovirt-web-ui

* Mon Mar 20 2017 Vojtech Szocs <vszocs@redhat.com> - 1.0.6-2
- Make sure the RPM version and/or release check is performed
  in both build.sh and check.sh scripts.

* Mon Mar 20 2017 Marek Libra - 1.0.6-1
- ovirt-ui-components 0.2.0 released as referenced from ovirt-web-ui

* Thu Mar 16 2017 Marek Libra - 1.0.5-1
- add new project cockpit-machines-ovirt-provider

* Thu Mar 2 2017 Greg Sheremeta <gshereme@redhat.com> - 1.0.4-7
- add fc24 repos.

* Tue Feb 21 2017 Greg Sheremeta <gshereme@redhat.com> - 1.0.4-6
- switch to noarch. Remove BuildRequires.

* Tue Feb 21 2017 Greg Sheremeta <gshereme@redhat.com> - 1.0.4-5
- fixed removal of 'http' urls from yarn.lock files. Only 'https'
  had been working.

* Tue Feb 21 2017 Ryan Barry <rbarry@redhat.com> - 1.0.4-4
- bumping version to pull in new cockpit-ovirt dependencies

* Fri Feb 17 2017 Marek Libra <mlibra@redhat.com> - 1.0.4-3
- bumping version to pull in new ovirt-web-ui dependencies

* Wed Feb 15 2017 Ryan Barry <rbarry@redhat.com> - 1.0.4-2
- bumping version to pull in new cockpit-ovirt dependencies

* Mon Feb 13 2017 Greg Sheremeta <gshereme@redhat.com> - 1.0.4-1
- bumping version to pull in new ovirt-js-dependencies dependencies

* Sat Feb 11 2017 Ryan Barry <rbarry@redhat.com> - 1.0.3-4
- Add dependencies for cockpit-ovirt

* Wed Feb 8 2017 Greg Sheremeta <gshereme@redhat.com> - 1.0.3-3
- bumping version to pull in new ovirt-js-dependencies dependencies

* Wed Feb 8 2017 Vojtech Szocs <vszocs@redhat.com> - 1.0.3-2
- Improve LICENSES file generation, parsing license information
  from Yarn's global cache instead of calling "yarn info" (which
  makes HTTP request) per each dependency (we have lots of 'em).

* Tue Feb 7 2017 Vojtech Szocs <vszocs@redhat.com> - 1.0.3-1
- "automation" directory cleanup.
- "setup-env.sh" now modifies the "yarn.lock" file to make sure
  it does not contain "resolved" entries containing HTTP links.
  This is needed in order to use Yarn's "offline mirror" feature.
- Node.js and Yarn versions are now specified in .packages file.

* Mon Feb 6 2017 Vojtech Szocs <vszocs@redhat.com> - 1.0.2-1
- Build script improvements.

* Mon Feb 6 2017 Greg Sheremeta <gshereme@redhat.com> - 1.0.1-6
- made yarn.lock file mandatory

* Mon Feb 6 2017 Greg Sheremeta <gshereme@redhat.com> - 1.0.1-5
- bumping version to pull in new dashboard dependencies

* Fri Feb 3 2017 Greg Sheremeta <gshereme@redhat.com> - 1.0.1-4
- fixed builds that were picking up pure-offline lock files

* Thu Feb 2 2017 Greg Sheremeta <gshereme@redhat.com> - 1.0.1-3
- fixed build to put artifacts in exported_artifacts

* Thu Feb 2 2017 Greg Sheremeta <gshereme@redhat.com> - 1.0.1-2
- configured to use Standard CI to build the RPM

* Tue Jan 24 2017 Greg Sheremeta <gshereme@redhat.com> - 1.0.1-1
- added ovirt-js-dependencies to projects.list

* Mon Jan 23 2017 Vojtech Szocs <vszocs@redhat.com> - 1.0.0-1
- Use Yarn to download JavaScript dependencies based on projects.list
  file. Use Yarn's "offline mirror" feature to download .tar.gz source
  of each dependency into an offline cache directory, which is part of
  the RPM package.
- Generate the LICENSES file based on the content of the offline cache
  directory via "yarn info {pkg_name}@{pkg_version} license" command.
- Require ovirt-engine-{nodejs,yarn} when building the package.

* Wed Dec 21 2016 Ramesh Nachimuthu <rnachimu@redhat.com> - 0.0.19-1
- Add ini.

* Sun Dec 18 2016 Juan Hernandez <juan.hernandez@redhat.com> - 0.0.18-1
- Add highlight.js.

* Wed Dec 14 2016 Martin Betak <mbetak@redhat.com> - 0.0.17-1
- Bump ovirt-ui-components version to 0.1.2.

* Fri Nov 25 2016 Martin Betak <mbetak@redhat.com> - 0.0.16-1
- Bump ovirt-ui-components version to 0.1.0.

* Fri Nov 18 2016 Vojtech Szocs <vszocs@redhat.com> - 0.0.15-1
- Bump Node.js version to 6.9.1.

* Mon Nov 14 2016 Martin Betak <mbetak@redhat.com> - 0.0.14-1
- Add new ovirt-web-ui dependencies based on create-react-app eject.

* Thu Aug 4 2016 Vojtech Szocs <vszocs@redhat.com> - 0.0.13-1
- Update build.sh to address various npm warnings when building RPM.
- npm modules to be included in RPM are now declared in dependencies,
  npm modules needed only for RPM build are now in devDependencies.
- Modules listed in devDependencies should no longer be mentioned in
  CHANGES.adoc file as they are not included in resulting RPM.

* Tue Aug 2 2016 Juan Hernandez <juan.hernandez@redhat.com> - 0.0.12-1
- Automatically calculate RPM dependencies using "find-requires".

* Mon Aug 1 2016 Juan Hernandez <juan.hernandez@redhat.com> - 0.0.11-1
- Don't extract the tarball, to avoid RPM file number limits.

* Thu Jul 28 2016 Vojtech Szocs <vszocs@redhat.com> - 0.0.10-1
- Add Intl API (ECMA-402) polyfill.

* Tue Jun 28 2016 Vojtech Szocs <vszocs@redhat.com> - 0.0.9-1
- Add test-related dependencies: Karma, Mocha, Chai, PhantomJS,
  Sinon, babel-polyfill and imports-loader.

* Thu May 26 2016 Vojtech Szocs <vszocs@redhat.com> - 0.0.8-1
- Add i18n-related dependencies: intl-messageformat, react-intl
  and json-loader for webpack.

* Tue May 10 2016 Vojtech Szocs <vszocs@redhat.com> - 0.0.7-1
- Add jQuery.

* Thu May 5 2016 Vojtech Szocs <vszocs@redhat.com> - 0.0.6-1
- Add setup-env.sh script.

* Fri Apr 22 2016 Marek Libra <mlibra@redhat.com> - 0.0.5-1
- Add po2json for webpack.

* Thu Apr 21 2016 Vojtech Szocs <vszocs@redhat.com> - 0.0.4-1
- Bump babel-core, copy-webpack-plugin, ESLint and its React
  plugin, React and React-DOM, style-loader and webpack.
- Add C3, D3 and ESLint config for Standard.js.

* Fri Apr 15 2016 Ryan Barry <rbarry@redhat.com> - 0.0.3-1
- Add classnames, Bootstrap, Patternfly, and plugins for webpack.

* Sun Apr 3 2016 Martin Betak <mbetak@redhat.com> - 0.0.2-1
- Added ESLint and ESLint Standard.js plugin.

* Thu Mar 31 2016 Juan Hernandez <juan.hernadez@redhat.com> - 0.0.1-1
- Build only for x86_64.

* Tue Mar 29 2016 Juan Hernandez <juan.hernadez@redhat.com> - 0.0.1-0.0
- Added ReactJS, Babel and Webpack.

* Tue Mar 29 2016 Juan Hernandez <juan.hernadez@redhat.com> - 0.0.0-0.2
- Added LICENSES.csv.

* Mon Mar 28 2016 Juan Hernandez <juan.hernadez@redhat.com> - 0.0.0-0.1
- Move the modules to a "node_modules" directory, as otherwise some
  tools, like "webpack", fail to find some of them.

* Sat Mar 5 2016 Juan Hernandez <juan.hernadez@redhat.com> - 0.0.0-0.0
- Initial packaging.
