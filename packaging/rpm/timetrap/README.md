# Fedora/COPR Packaging (`ruby-timetrap`)

This directory contains minimal RPM packaging for building the upstream `timetrap` gem
as a Fedora package that can live in the same COPR repo as `ruby-qt` and `ruby-qtimetrap`.

## Files

- `ruby-timetrap.spec` - RPM spec for `ruby-timetrap`
- `Makefile` - helper to fetch the upstream gem and build an SRPM

## Build SRPM locally

```bash
make -C packaging/rpm/timetrap srpm
```

The generated SRPM will be created under:

```text
packaging/rpm/timetrap/.rpmbuild/SRPMS/*.src.rpm
```

## Submit build to COPR

```bash
copr-cli build ruby-qt-stack packaging/rpm/timetrap/.rpmbuild/SRPMS/*.src.rpm
```

Build `ruby-timetrap` before `ruby-qtimetrap`, so the latter can resolve its runtime dependency
from the same COPR repository.
