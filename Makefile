# htrust Makefile

CARGO ?= cargo
CARGO_BUILD_FLAGS ?= --release

PREFIX ?= $(HOME)/.local
BINDIR ?= $(PREFIX)/bin

BINARY ?= target/release/htrust

.PHONY: all build install test clean

all: build

build:
	$(CARGO) build $(CARGO_BUILD_FLAGS)

install: build
	install -d $(BINDIR)
	install -m 0755 $(BINARY) $(BINDIR)/htrust

test:
	./tests/run.sh

clean:
	$(CARGO) clean
