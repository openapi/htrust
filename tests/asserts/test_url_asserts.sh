#!/usr/bin/env bash
# Negative / side-case asserts for: htrust url

set -euo pipefail
source "$(dirname "$0")/lib.sh"
require_bin

echo "==> url asserts"

unset OPENAPI_TOKEN OPENAPI_SANDBOX_TOKEN

# Missing token.
run "$BIN url https://example.com"
assert_rc "url without token returns 1" 1
assert_stderr_contains "error mentions OPENAPI_TOKEN" "OPENAPI_TOKEN"

# Missing positional value.
run "$BIN url"
assert_rc "url without value returns 2" 2
assert_stderr_contains "missing value shows usage" "Usage:"

# Unknown flag.
run "$BIN url https://example.com --bad-flag"
assert_rc "unknown flag returns 2" 2
assert_stderr_contains "unknown flag shows error" "error:"

# Static validation rejects bad input before the API is called.
run "$BIN url not-a-url"
assert_rc "invalid url returns 1" 1
assert_stderr_contains "error mentions invalid format" "invalid url format"

# Live JSON validation when a sandbox token is available.
if [ -n "${OPENAPI_SANDBOX_TOKEN:-}" ]; then
  run "OPENAPI_SANDBOX_TOKEN=$OPENAPI_SANDBOX_TOKEN $BIN --sandbox url https://example.com"
  assert_rc "sandbox url returns 0" 0
  assert_json "sandbox url returns JSON"

  run "OPENAPI_SANDBOX_TOKEN=$OPENAPI_SANDBOX_TOKEN $BIN --sandbox url https://example.com --detail"
  assert_rc "sandbox url --detail returns 0" 0
  assert_json "sandbox url --detail returns JSON"
fi

summary
