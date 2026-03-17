# Fedora/COPR Packaging (`ruby-qtimetrap`)

This directory contains minimal RPM packaging for building Fedora packages in COPR.

Related package recipes that live in this repository:

- `packaging/rpm` - `ruby-qtimetrap`
- `packaging/rpm/timetrap` - upstream `timetrap` CLI used by QTimetrap

## Files

- `ruby-qtimetrap.spec` - RPM spec for `ruby-qtimetrap`
- `qtimetrap.desktop` - desktop launcher file
- `Makefile` - helper to build SRPM from current git checkout

## Prerequisites (local)

```bash
sudo dnf install -y rpm-build git curl
```

## Build SRPM locally

From repository root:

```bash
make -C packaging/rpm srpm
```

SRPM will be created under:

```text
packaging/rpm/.rpmbuild/SRPMS/*.src.rpm
```

By default, SRPM is built with neutral `dist` (`--define "dist %{nil}"`),
so file names are distro-agnostic.

## Submit build to COPR

1. Install and configure `copr-cli`:

```bash
sudo dnf install -y copr-cli
mkdir -p ~/.config
# put your API credentials into ~/.config/copr
```

2. Create project once (example):

```bash
copr-cli create ruby-qtimetrap --chroot fedora-41-x86_64
```

3. Submit SRPM:

```bash
copr-cli build ruby-qt-stack packaging/rpm/.rpmbuild/SRPMS/*.src.rpm
```

## Notes

- RPM package name is `ruby-qtimetrap` (gem name stays `qtimetrap`).
- Runtime dependency on `timetrap` CLI is packaged separately as `ruby-timetrap`.
- `ruby-qtimetrap` requires a working `ruby-qt` RPM with built native extension
  (`qt_ruby_bridge.so` + extension metadata for system Ruby ABI).
- Desktop file and app icons are installed into standard system paths.
