#!/usr/bin/env bash
# Negative / side-case asserts for: htrust email

set -euo pipefail
source "$(dirname "$0")/lib.sh"
require_bin

echo "==> email asserts"

unset OPENAPI_TOKEN OPENAPI_SANDBOX_TOKEN

# Missing token.
run "$BIN email info@example.com"
assert_rc "email without token returns 1" 1
assert_stderr_contains "error mentions OPENAPI_TOKEN" "OPENAPI_TOKEN"

# Missing positional value.
run "$BIN email"
assert_rc "email without value returns 2" 2
assert_stderr_contains "missing value shows usage" "Usage:"

# Unknown flag.
run "$BIN email info@example.com --bad-flag"
assert_rc "unknown flag returns 2" 2
assert_stderr_contains "unknown flag shows error" "error:"

# Static validation rejects bad input before the API is called.
run "$BIN email not-an-email"
assert_rc "invalid email returns 1" 1
assert_stderr_contains "error mentions invalid format" "invalid email format"

# Live JSON validation when a sandbox token is available.
if [ -n "${OPENAPI_SANDBOX_TOKEN:-}" ]; then
  run "OPENAPI_SANDBOX_TOKEN=$OPENAPI_SANDBOX_TOKEN $BIN --sandbox email info@example.com"
  assert_rc "sandbox email returns 0" 0
  assert_json "sandbox email returns JSON"

  run "OPENAPI_SANDBOX_TOKEN=$OPENAPI_SANDBOX_TOKEN $BIN --sandbox email info@example.com --detail"
  assert_rc "sandbox email --detail returns 0" 0
  assert_json "sandbox email --detail returns JSON"
fi

summary
