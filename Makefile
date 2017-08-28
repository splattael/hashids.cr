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

.PHONY: benchmarks
benchmarks:
	rm -f benchmarks/run
	$(CRYSTAL_BIN) build --release --no-debug benchmarks/run.cr -o benchmarks/run
	benchmarks/run

release:
	git commit -av -e -m "Release v${VERSION}" && \
	git tag -f v${VERSION} && \
	git push && \
	git push --tags -f

.PHONY: clean
clean:
	rm -fr .crystal
