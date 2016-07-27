CRYSTAL_BIN ?= $(shell which crystal)
PREFIX ?= $(CURDIR)
BINDIR = $(PREFIX)/bin
BINARY = $(BINDIR)/server
VERSION = $(shell $(CRYSTAL_BIN) run $(BINDIR)/version)

all: spec

.PHONY: spec
spec:
	$(CRYSTAL_BIN) spec

update:
	shards update

.PHONY: clean
clean:
	rm -fr .crystal $(BINARY)
