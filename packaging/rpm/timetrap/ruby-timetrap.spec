Name:           ruby-timetrap
Version:        1.15.5
Release:        1%{?dist}
Summary:        Command line time tracker written in Ruby

License:        MIT
URL:            https://github.com/samg/timetrap
Source0:        timetrap-%{version}.gem

BuildRequires:  ruby
BuildRequires:  ruby-devel
BuildRequires:  rubygems-devel
BuildRequires:  rubygem-rake

Requires:       ruby
Requires:       rubygem(chronic)
Requires:       rubygem(sequel)
Requires:       rubygem(sqlite3)

%global gem_name timetrap
%global gem_dir /usr/share/gems
%global gem_bindir %{gem_dir}/bin
%global gem_instdir %{gem_dir}/gems/%{gem_name}-%{version}
%global debug_package %{nil}

%description
Timetrap is a simple command line time tracker written in Ruby. It provides an
easy to use CLI for tracking what you spend your time on.

This package installs the upstream timetrap gem and exposes its executables as
`t` and `timetrap`.

%prep

%build

%install
mkdir -p %{buildroot}

gem install \
  --local \
  --force \
  --ignore-dependencies \
  --no-document \
  --install-dir %{buildroot}%{gem_dir} \
  %{SOURCE0}

# Expose executables in PATH.
install -Dpm755 %{buildroot}%{gem_bindir}/t %{buildroot}%{_bindir}/t
install -Dpm755 %{buildroot}%{gem_bindir}/timetrap %{buildroot}%{_bindir}/timetrap
rm -f %{buildroot}%{gem_bindir}/t
rm -f %{buildroot}%{gem_bindir}/timetrap
rm -f %{buildroot}%{gem_bindir}/dev_t

# Avoid absolute BUILDROOT leaks in logs.
find %{buildroot} -type f \( -name gem_make.out -o -name mkmf.log \) -delete

%files
%{_bindir}/t
%{_bindir}/timetrap
%{gem_dir}/cache/%{gem_name}-%{version}.gem
%{gem_instdir}
%{gem_dir}/specifications/%{gem_name}-%{version}.gemspec

%changelog
* Tue Mar 17 2026 Maksim Veynberg <mv@cj264.ru> - 1.15.5-1
- Initial Fedora/COPR packaging for timetrap
