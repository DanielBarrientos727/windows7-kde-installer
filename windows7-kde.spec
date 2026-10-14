Name:           windows7-kde
Version:        0.1.0
Release:        1%{?dist}
Summary:        Windows 7-inspired appearance installer for KDE Plasma

License:        GPL-3.0-or-later
URL:            https://github.com/DanielBarrientos727/windows7-kde-installer
Source0:        https://github.com/DanielBarrientos727/windows7-kde-installer/archive/refs/heads/v%{version}.tar.gz

BuildArch:      noarch
BuildRequires:  bash
Requires:       bash
Requires:       git
Requires:       kvantum
Requires:       plasma-workspace >= 6.0

%description
A user-level installer for a Windows 7-inspired KDE Plasma appearance.
It downloads the community theme components, backs up selected user
configuration files, and provides a restore option. The command must be
run from an active KDE Plasma session as the desktop user, not as root.

%prep
%setup -q -c -T
tar -xzf %{SOURCE0} --strip-components=1

%build
# This package installs shell scripts; there is no compilation step.

%check
bash -n install.sh
bash -n quick-install.sh
bash -n packaging/fedora/windows7-kde

%install
install -Dpm 0755 install.sh %{buildroot}%{_libexecdir}/windows7-kde/install.sh
install -Dpm 0755 packaging/fedora/windows7-kde %{buildroot}%{_bindir}/windows7-kde

%files
%license LICENSE
%doc README.md
%{_bindir}/windows7-kde
%{_libexecdir}/windows7-kde/install.sh

%changelog
* Wed Oct 14 2026 Daniel Barrientos <danielbarrientos727@users.noreply.github.com> - 0.1.0-1
- Initial Fedora RPM package
