# htrust Makefile

CARGO ?= cargo
CARGO_BUILD_FLAGS ?= --release

PREFIX ?= $(HOME)/.local
BINDIR ?= $(PREFIX)/bin

BINARY ?= target/release/htrust

.PHONY: all build install test clean

all: build

build:
	@$(CARGO) build $(CARGO_BUILD_FLAGS)

install: build
	@printf "\033[1;32m[htrust]\033[0m Initializing secure install sequence...\n"
	@printf "\033[1;34m[*]\033[0m Target directory: \033[1;33m$(BINDIR)\033[0m\n"
	@install -d $(BINDIR)
	@printf "\033[1;34m[*]\033[0m Installing binary: \033[1;36mhtrust\033[0m\n"
	@install -m 0755 $(BINARY) $(BINDIR)/htrust
	@printf "\033[1;32m[✓]\033[0m htrust installed successfully at \033[1;33m$(BINDIR)/htrust\033[0m\n"
	@if command -v htrust >/dev/null 2>&1; then \
		printf "\033[1;32m[✓]\033[0m Verified in PATH: "; \
		htrust --version; \
	else \
		printf "\033[1;33m[!]\033[0m \033[1;33m$(BINDIR)\033[0m may not be in your PATH\n"; \
		printf "\033[1;33m[!]\033[0m Add it with: \033[1;36mexport PATH=\"$(BINDIR):\$$PATH\"\033[0m\n"; \
	fi
	@printf "\033[1;32m[DONE]\033[0m Open Source Trust for Humans is ready.\n"

test: cargo-test test-smoke test-asserts

cargo-test:
	$(CARGO) test

test-smoke:
	./tests/run.sh

test-asserts:
	./tests/asserts/run.sh

clean:
	$(CARGO) clean
