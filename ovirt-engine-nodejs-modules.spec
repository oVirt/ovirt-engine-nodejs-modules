Name: ovirt-engine-nodejs-modules
Version: 1.0.1
Release: 6%{?dist}
Summary: Node.js modules required to build oVirt JavaScript applications
Group: Virtualization/Management
License: Multiple
URL: http://ovirt.org
Source0: %{?_tar}
Source1: LICENSES
Source2: setup-env.sh

Requires: ovirt-engine-nodejs >= 6.9.4
Requires: ovirt-engine-yarn >= 0.19.1

%description
Node.js modules required to build oVirt JavaScript applications.

%prep

# Copy additional files to build directory:
cp %{SOURCE1} .
cp %{SOURCE2} .

%install

# Create the destination directory in build root:
mkdir -p %{buildroot}%{_datadir}/%{name}

# Uncompress the offline cache tarball:
tar -xf %{SOURCE0} -C %{buildroot}%{_datadir}/%{name}

# Copy additional files to build root:
cp %{SOURCE2} %{buildroot}%{_datadir}/%{name}/.

%files
%license LICENSES
%{_datadir}/%{name}

%changelog
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
