CRYSTAL_BIN ?= $(shell which crystal)
PREFIX ?= $(CURDIR)
BINDIR = $(PREFIX)/bin
VERSION = $(shell $(CRYSTAL_BIN) run $(BINDIR)/version)

all: spec

.PHONY: spec
spec:
	$(CRYSTAL_BIN) spec

update:
	shards update

release:
	git commit -av -e -m "Release v${VERSION}" && \
	git tag -f v${VERSION} && \
	git push && \
	git push --tags -f

.PHONY: clean
clean:
	rm -fr .crystal
