#!/usr/bin/env bash
# Negative / side-case asserts for: htrust mobile

set -euo pipefail
source "$(dirname "$0")/lib.sh"
require_bin

echo "==> mobile asserts"

unset OPENAPI_TOKEN OPENAPI_SANDBOX_TOKEN

# Missing token.
run "$BIN mobile +393331234567"
assert_rc "mobile without token returns 1" 1
assert_stderr_contains "error mentions OPENAPI_TOKEN" "OPENAPI_TOKEN"

# Missing positional value.
run "$BIN mobile"
assert_rc "mobile without value returns 2" 2
assert_stderr_contains "missing value shows usage" "Usage:"

# Unknown flag.
run "$BIN mobile +393331234567 --bad-flag"
assert_rc "unknown flag returns 2" 2
assert_stderr_contains "unknown flag shows error" "error:"

# Static validation rejects bad input before the API is called.
run "$BIN mobile not-a-number"
assert_rc "invalid mobile returns 1" 1
assert_stderr_contains "error mentions invalid format" "invalid mobile format"

# --details is a synonym for --detail.
if [ -n "${OPENAPI_SANDBOX_TOKEN:-}" ]; then
  run "OPENAPI_SANDBOX_TOKEN=$OPENAPI_SANDBOX_TOKEN $BIN --sandbox mobile +393331234567 --details"
  assert_rc "--details alias returns 0" 0
fi

# Live JSON validation when a sandbox token is available.
if [ -n "${OPENAPI_SANDBOX_TOKEN:-}" ]; then
  run "OPENAPI_SANDBOX_TOKEN=$OPENAPI_SANDBOX_TOKEN $BIN --sandbox mobile +393331234567"
  assert_rc "sandbox mobile returns 0" 0
  assert_json "sandbox mobile returns JSON"

  run "OPENAPI_SANDBOX_TOKEN=$OPENAPI_SANDBOX_TOKEN $BIN --sandbox mobile +393331234567 --detail"
  assert_rc "sandbox mobile --detail returns 0" 0
  assert_json "sandbox mobile --detail returns JSON"
fi

summary
