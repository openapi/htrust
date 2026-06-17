# htrust

Open Source Trust for Humans.

`htrust` is a Rust CLI for Linux sysadmins, shell scripts, and agentic tooling that need to check whether real-world information can be trusted before acting on it.

The interface is intentionally flat: one command per claim type, one positional value to check, JSON on stdout.

---

## Table of contents

- [Installation](#installation)
- [Configuration](#configuration)
- [Commands](#commands)
  - [`htrust info`](#htrust-info)
  - [`htrust mobile`](#htrust-mobile)
  - [`htrust email`](#htrust-email)
  - [`htrust ip`](#htrust-ip)
  - [`htrust url`](#htrust-url)
  - [Global flags](#global-flags)
- [Endpoint mapping](#endpoint-mapping)
- [Exit codes](#exit-codes)
- [Output format](#output-format)
- [Development](#development)
- [Testing](#testing)
- [Makefile targets](#makefile-targets)
- [Project layout](#project-layout)

---

## Installation

### Build from source

You need a working Rust toolchain (edition 2021 or newer) and `cargo`.

```bash
git clone https://github.com/openapi/htrust.git
cd htrust
cargo build --release
```

The binary is produced at:

```text
target/release/htrust
```

### Local install with Make

```bash
make install
```

This builds the release binary and copies it to `~/.local/bin/htrust`. Make sure `~/.local/bin` is in your `PATH`.

To install to a custom prefix:

```bash
make install PREFIX=/usr/local
```

The binary will be copied to `$PREFIX/bin/htrust`.

---

## Configuration

`htrust` reads API tokens from the environment.

| Variable | Required by | Description |
|----------|-------------|-------------|
| `OPENAPI_TOKEN` | production commands | Production token for `trust.openapi.com` |
| `OPENAPI_SANDBOX_TOKEN` | `--sandbox` commands | Sandbox token for `test.trust.openapi.com` |

Set them in your shell or in a `.env` file:

```bash
export OPENAPI_TOKEN=your-production-token
export OPENAPI_SANDBOX_TOKEN=your-sandbox-token
```

A ready-to-edit example is provided in `.env.example`.

---

## Commands

### `htrust info`

Prints runtime configuration: sandbox mode, token status, and CLI version.

```bash
htrust info
```

Example output:

```text
htrust runtime
  sandbox: false
  token env: OPENAPI_TOKEN (set)
```

`info` does **not** perform any API call.

---

### `htrust mobile`

Verifies a mobile phone number.

```bash
# basic check
htrust mobile +393331234567

# advanced / detailed check
htrust mobile +393331234567 --detail
```

| Argument | Description |
|----------|-------------|
| `VALUE` | Phone number with international prefix (e.g. `+393331234567`) |

`--detail` selects the richer endpoint when the API exposes both a base and an advanced check.

---

### `htrust email`

Verifies an email address.

```bash
htrust email info@example.com
htrust email info@example.com --detail
```

| Argument | Description |
|----------|-------------|
| `VALUE` | Email address to verify |

---

### `htrust ip`

Verifies an IP address.

```bash
htrust ip 8.8.8.8
```

| Argument | Description |
|----------|-------------|
| `VALUE` | IPv4 or IPv6 address |

`--detail` is accepted for interface consistency but the underlying endpoint is always the advanced one.

---

### `htrust url`

Verifies a URL.

```bash
htrust url https://example.com
```

| Argument | Description |
|----------|-------------|
| `VALUE` | Absolute URL to verify |

Like `ip`, `--detail` is accepted but maps to the advanced endpoint.

---

### Global flags

| Flag | Description |
|------|-------------|
| `--sandbox` | Use the sandbox environment (`test.trust.openapi.com`) and `OPENAPI_SANDBOX_TOKEN` |
| `-h`, `--help` | Print help |
| `-V`, `--version` | Print version |

Examples:

```bash
htrust --sandbox info
htrust --sandbox mobile +393331234567 --detail
```

---

## Endpoint mapping

| Command | Default endpoint | `--detail` endpoint |
|---------|------------------|---------------------|
| `mobile` | `mobile-start` | `mobile-advanced` |
| `email` | `email-start` | `email-advanced` |
| `ip` | `ip-advanced` | `ip-advanced` |
| `url` | `url-advanced` | `url-advanced` |

Base URL:

- production: `https://trust.openapi.com`
- sandbox: `https://test.trust.openapi.com`

The final URL is built as:

```text
{base_url}/{endpoint}/{value}
```

For example:

```text
https://trust.openapi.com/mobile-start/+393331234567
```

---

## Exit codes

| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | CLI usage error or API error |
| `2` | Missing required environment variable or empty token |

---

## Output format

All trust commands print a JSON object to stdout. The exact schema depends on the OpenAPI trust endpoint.

Example (schema may vary):

```json
{
  "status": "verified",
  "trust_score": 94
}
```

Errors are printed to stderr.

---

## Development

Build the debug binary:

```bash
cargo build
```

Run the CLI from the build directory:

```bash
./target/debug/htrust info
```

Run clippy and formatting checks:

```bash
cargo clippy --all-targets
cargo fmt --check
```

---

## Testing

### Rust unit tests

Unit tests live inside the source files under `src/` in `#[cfg(test)]` modules.

```bash
cargo test
```

### Bash integration test suite

The project also includes a pure Bash test suite in `tests/`.
Each command has its own self-contained test file that doubles as a usage example:

```text
tests/
├── run.sh            # orchestrates all tests
├── lib.sh            # shared helpers
├── test_info.sh      # htrust info examples
├── test_mobile.sh    # htrust mobile examples
├── test_email.sh     # htrust email examples
├── test_ip.sh        # htrust ip examples
└── test_url.sh       # htrust url examples
```

Run all tests:

```bash
make test
```

or directly:

```bash
./tests/run.sh
```

Run a single command test:

```bash
./tests/test_mobile.sh
```

Each file:

1. shows the intended usage in comments,
2. checks missing-token and missing-argument errors,
3. if `OPENAPI_SANDBOX_TOKEN` is set, performs a live sandbox call and validates JSON output.

To run live tests against the sandbox:

```bash
export OPENAPI_SANDBOX_TOKEN=your-sandbox-token
make test
```

---

## Makefile targets

| Target | Description |
|--------|-------------|
| `make` or `make build` | Build the release binary |
| `make install` | Build and install to `~/.local/bin` (or `$PREFIX/bin`) |
| `make test` | Run the Bash test suite |
| `make clean` | Remove build artifacts |

---

## Project layout

```text
.
├── Cargo.toml
├── Makefile
├── README.md
├── .env.example
├── src/
│   ├── main.rs          # CLI entrypoint
│   ├── cli.rs           # clap argument definitions
│   ├── client.rs        # HTTP client and auth
│   ├── config.rs        # Token loading
│   └── commands/
│       ├── info.rs      # htrust info
│       ├── mod.rs       # command module exports
│       └── trust.rs     # mobile/email/ip/url implementation
└── tests/
    ├── lib.sh           # shared test helpers
    ├── run.sh           # test runner
    ├── test_info.sh     # info command examples/tests
    ├── test_mobile.sh   # mobile command examples/tests
    ├── test_email.sh    # email command examples/tests
    ├── test_ip.sh       # ip command examples/tests
    └── test_url.sh      # url command examples/tests
```

---

## Scope

This first cut wraps the current `trust.openapi.com` subset:

- `mobile-start`
- `mobile-advanced`
- `email-start`
- `email-advanced`
- `ip-advanced`
- `url-advanced`

The long-term shape can expand to commands like `htrust iban ...` or `htrust vat ...`, but those endpoints are not wired in this first baseline yet.
