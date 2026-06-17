#!/usr/bin/env bash
# htrust Bash test suite.
# Run with: ./tests/run.sh
# Run live sandbox tests with: OPENAPI_SANDBOX_TOKEN=xxx ./tests/run.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=tests/lib.sh
source "$SCRIPT_DIR/lib.sh"

HTRUST="$PROJECT_ROOT/target/release/htrust"

log_info "Project root: $PROJECT_ROOT"

# ---------------------------------------------------------------------------
# Build
# ---------------------------------------------------------------------------
log_info "Building release binary..."
(
  cd "$PROJECT_ROOT"
  cargo build --release
)

if [ ! -x "$HTRUST" ]; then
  log_fail "Binary not found at $HTRUST"
  summary
  exit 1
fi

log_info "Using binary: $HTRUST"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Run a test case with the binary.
htrust_run() {
  run_cmd "\"$HTRUST\" $*"
}

# ---------------------------------------------------------------------------
# Tests: help and version
# ---------------------------------------------------------------------------

log_info "Testing CLI surface..."

htrust_run --help
assert_contains "--help prints usage" "htrust" "$stdout"
assert_rc "--help exit code" 0 "$rc"

htrust_run --version
assert_contains "--version prints version" "htrust" "$stdout"
assert_rc "--version exit code" 0 "$rc"

htrust_run
assert_contains "no subcommand prints help" "Usage:" "$stdout"

# ---------------------------------------------------------------------------
# Tests: info
# ---------------------------------------------------------------------------

log_info "Testing 'htrust info'..."

clear_tokens
htrust_run info
assert_eq "info works without token" 0 "$rc"
assert_contains "info reports runtime" "htrust runtime" "$stdout"

htrust_run --sandbox info
assert_eq "info --sandbox works without token" 0 "$rc"
assert_contains "info --sandbox reports sandbox" "sandbox: true" "$stdout"

# ---------------------------------------------------------------------------
# Tests: missing tokens
# ---------------------------------------------------------------------------

log_info "Testing missing-token behavior..."

clear_tokens

for cmd in mobile email ip url; do
  htrust_run "$cmd" "dummy-value"
  assert_rc "$cmd fails without token" 1 "$rc"
  assert_contains "$cmd error mentions token" "OPENAPI_TOKEN" "$stderr"
done

# ---------------------------------------------------------------------------
# Tests: argument parsing
# ---------------------------------------------------------------------------

log_info "Testing argument parsing..."

clear_tokens

# Missing positional value.
htrust_run mobile
assert_rc "mobile without value fails" 2 "$rc"
assert_contains "mobile without value shows usage" "Usage:" "$stderr"

htrust_run email
assert_rc "email without value fails" 2 "$rc"

htrust_run ip
assert_rc "ip without value fails" 2 "$rc"

htrust_run url
assert_rc "url without value fails" 2 "$rc"

# Unknown flags.
htrust_run mobile +393331234567 --unknown-flag
assert_rc "unknown flag fails" 2 "$rc"
assert_contains "unknown flag error is shown" "error:" "$stderr"

# ---------------------------------------------------------------------------
# Tests: live sandbox calls (only when OPENAPI_SANDBOX_TOKEN is set)
# ---------------------------------------------------------------------------

if [ -z "${OPENAPI_SANDBOX_TOKEN:-}" ]; then
  log_skip "live sandbox tests (set OPENAPI_SANDBOX_TOKEN to enable)"
else
  log_info "Running live sandbox tests..."

  # Use well-known, stable inputs.
  htrust_run --sandbox mobile "+393331234567"
  assert_rc "sandbox mobile returns success" 0 "$rc"
  assert_valid_json "sandbox mobile returns valid JSON" "$stdout"

  htrust_run --sandbox mobile "+393331234567" --detail
  assert_rc "sandbox mobile --detail returns success" 0 "$rc"
  assert_valid_json "sandbox mobile --detail returns valid JSON" "$stdout"

  htrust_run --sandbox email "test@example.com"
  assert_rc "sandbox email returns success" 0 "$rc"
  assert_valid_json "sandbox email returns valid JSON" "$stdout"

  htrust_run --sandbox ip "8.8.8.8"
  assert_rc "sandbox ip returns success" 0 "$rc"
  assert_valid_json "sandbox ip returns valid JSON" "$stdout"

  htrust_run --sandbox url "https://example.com"
  assert_rc "sandbox url returns success" 0 "$rc"
  assert_valid_json "sandbox url returns valid JSON" "$stdout"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

summary
