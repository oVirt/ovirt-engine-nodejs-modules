.PHONY: installdeps srpm

installdeps:
	dnf -y install git jq wget rpmlint nodejs
	dnf --repofrompath=ovirt-master-snapshot,https://download.copr.fedorainfracloud.org/results/ovirt/ovirt-master-snapshot/fedora-34-x86_64/ install -y ovirt-engine-nodejs-modules

# explicity mark the copr generated git repo directory (which is done prior to the mock
# call to the make_srpm and will be the current pwd) as safe for git commands
git-safe:
	git config --global --add safe.directory "$(shell pwd)"

srpm: installdeps git-safe
	./automation/build.sh copr
	cp exported-artifacts/*.src.rpm $(outdir)
