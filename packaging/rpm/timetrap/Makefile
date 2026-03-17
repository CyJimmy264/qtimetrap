SPEC := ruby-timetrap.spec
NAME := ruby-timetrap
VERSION := $(shell awk '/^Version:/ {print $$2}' $(SPEC))
TOPDIR ?= $(CURDIR)/.rpmbuild
SOURCEDIR := $(TOPDIR)/SOURCES
SRPMDIR := $(TOPDIR)/SRPMS
GEM_SOURCE := https://rubygems.org/downloads/timetrap-$(VERSION).gem

.PHONY: srpm clean print-version

print-version:
	@echo $(VERSION)

srpm: $(SOURCEDIR)/timetrap-$(VERSION).gem
	rpmbuild -bs $(SPEC) \
		--define "_topdir $(TOPDIR)" \
		--define "_sourcedir $(SOURCEDIR)" \
		--define "_srcrpmdir $(SRPMDIR)" \
		--define "dist %{nil}"
	@echo
	@echo "SRPM:"
	@ls -1 $(SRPMDIR)/*.src.rpm

$(SOURCEDIR)/timetrap-$(VERSION).gem:
	mkdir -p $(SOURCEDIR)
	curl -L --fail --output $@ $(GEM_SOURCE)

clean:
	rm -rf $(TOPDIR)
