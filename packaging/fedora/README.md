# Fedora COPR packaging

This repository contains the Fedora RPM spec and a GitHub Actions build check. **The package is not published to COPR yet.**

## Package behaviour

- Package name: \`windows7-kde\`.
- Installs the \`windows7-kde\` launcher and the installer script under \`/usr/libexec/windows7-kde/\`.
- Requires Fedora's \`plasma-workspace\` 6+, \`kvantum\`, \`git\`, and \`bash\`.
- Does not alter a user's desktop during the RPM transaction. The user runs \`windows7-kde\` from the active KDE Plasma session to apply the appearance.
- \`windows7-kde --restore\` restores the appearance settings saved by the installer. Removing the RPM does not remove theme settings already installed into the user's home directory.

## Build locally

From a checkout of the version branch:

~~~bash
sudo dnf install rpm-build curl
mkdir -p "$HOME/rpmbuild"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
cp windows7-kde.spec "$HOME/rpmbuild/SPECS/"
curl -fL "https://github.com/DanielBarrientos727/windows7-kde-installer/archive/refs/heads/v0.1.0.tar.gz" \
  -o "$HOME/rpmbuild/SOURCES/v0.1.0.tar.gz"
rpmbuild -ba "$HOME/rpmbuild/SPECS/windows7-kde.spec" \
  --define "_topdir $HOME/rpmbuild"
~~~

## Publish via COPR

Creating/publishing the COPR project requires the owner's Fedora Account System/COPR login; API tokens must never be committed to this repository.

1. Sign in at https://copr.fedorainfracloud.org/ and create a project named \`windows7-kde\`.
2. Configure the build target for Fedora 44 x86_64 initially.
3. Add this GitHub repository as a Git/SCM source, select branch \`v0.1.0\`, and set the spec path to \`windows7-kde.spec\`. COPR supports builds from Git repositories containing a spec file: https://docs.copr.fedorainfracloud.org/user_documentation.html
4. Trigger the build and inspect the build log. Publish only after it succeeds.
5. Once the COPR project contains a successful package build, users can install it with (replace \`YOUR_COPR_USERNAME\` with the actual COPR namespace):

~~~bash
sudo dnf install dnf-plugins-core
sudo dnf copr enable YOUR_COPR_USERNAME/windows7-kde
sudo dnf install windows7-kde
windows7-kde
~~~

The repository enable step is one-time setup per system. After that, DNF can install and update the package. Do not present the DNF install command as available until the COPR project is created and a successful build is published.
