Name:           ruby-qtimetrap
Version:        0.1.2
Release:        1%{?dist}
Summary:        Desktop Timetrap UI built with Ruby + Qt

License:        BSD-2-Clause
URL:            https://github.com/CyJimmy264/qtimetrap
Source0:        %{name}-%{version}.tar.gz
Source1:        qtimetrap.desktop

BuildRequires:  ruby
BuildRequires:  ruby-devel
BuildRequires:  rubygems-devel
BuildRequires:  rubygem-rake
BuildRequires:  rubygem-ffi
BuildRequires:  desktop-file-utils

Requires:       ruby
Requires:       ruby-qt >= 0.1.7
Requires:       ruby-timetrap
Requires:       rubygem(qt) >= 0.1.7
Requires:       rubygem(zeitwerk)

%global gem_name qtimetrap
%global gem_dir /usr/share/gems
%global gem_bindir %{gem_dir}/bin
%global gem_instdir %{gem_dir}/gems/%{gem_name}-%{version}
%global debug_package %{nil}

%description
QTimetrap is a desktop UI for Timetrap, built with Ruby and Qt in MVVM style.

This package installs the gem, executable wrapper, desktop entry, and app icon.

%prep
%autosetup -n %{name}-%{version}

%build
gem build qtimetrap.gemspec --output %{gem_name}-%{version}.gem

%install
mkdir -p %{buildroot}

gem install \
  --local \
  --force \
  --ignore-dependencies \
  --no-document \
  --install-dir %{buildroot}%{gem_dir} \
  %{gem_name}-%{version}.gem

# Expose executable in PATH.
install -Dpm755 %{buildroot}%{gem_bindir}/qtimetrap %{buildroot}%{_bindir}/qtimetrap
rm -f %{buildroot}%{gem_bindir}/qtimetrap

# Desktop entry and icons.
install -Dpm644 %{SOURCE1} %{buildroot}%{_datadir}/applications/qtimetrap.desktop
install -Dpm644 app/assets/icons/qtimetrap-icon.svg \
  %{buildroot}%{_datadir}/icons/hicolor/scalable/apps/qtimetrap.svg
install -Dpm644 app/assets/icons/qtimetrap-icon-128.png \
  %{buildroot}%{_datadir}/icons/hicolor/128x128/apps/qtimetrap.png
install -Dpm644 app/assets/icons/qtimetrap-icon-256.png \
  %{buildroot}%{_datadir}/icons/hicolor/256x256/apps/qtimetrap.png
install -Dpm644 app/assets/icons/qtimetrap-icon-512.png \
  %{buildroot}%{_datadir}/icons/hicolor/512x512/apps/qtimetrap.png

desktop-file-validate %{buildroot}%{_datadir}/applications/qtimetrap.desktop

# Avoid absolute BUILDROOT leaks in logs.
find %{buildroot} -type f \( -name gem_make.out -o -name mkmf.log \) -delete

%files
%license LICENSE
%doc README.md
%{_bindir}/qtimetrap
%{_datadir}/applications/qtimetrap.desktop
%{_datadir}/icons/hicolor/scalable/apps/qtimetrap.svg
%{_datadir}/icons/hicolor/128x128/apps/qtimetrap.png
%{_datadir}/icons/hicolor/256x256/apps/qtimetrap.png
%{_datadir}/icons/hicolor/512x512/apps/qtimetrap.png
%{gem_dir}/cache/%{gem_name}-%{version}.gem
%{gem_instdir}
%{gem_dir}/specifications/%{gem_name}-%{version}.gemspec
%{gem_dir}/extensions

%changelog
* Tue Mar 17 2026 Maksim Veynberg <mv@cj264.ru> - 0.1.2-1
- Update package to 0.1.2

* Sat Mar 14 2026 Maksim Veynberg <mv@cj264.ru> - 0.1.1-1
- Update package to 0.1.1

* Thu Mar 05 2026 Maksim Veynberg <mv@cj264.ru> - 0.1.0-1
- Initial Fedora/COPR packaging for ruby-qtimetrap
