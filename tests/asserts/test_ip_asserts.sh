#!/usr/bin/env bash
# Negative / side-case asserts for: htrust ip

set -euo pipefail
source "$(dirname "$0")/lib.sh"
require_bin

echo "==> ip asserts"

unset OPENAPI_TOKEN OPENAPI_SANDBOX_TOKEN

# Missing token.
run "$BIN ip 8.8.8.8"
assert_rc "ip without token returns 1" 1
assert_stderr_contains "error mentions OPENAPI_TOKEN" "OPENAPI_TOKEN"

# Missing positional value.
run "$BIN ip"
assert_rc "ip without value returns 2" 2
assert_stderr_contains "missing value shows usage" "Usage:"

# Unknown flag.
run "$BIN ip 8.8.8.8 --bad-flag"
assert_rc "unknown flag returns 2" 2
assert_stderr_contains "unknown flag shows error" "error:"

# Static validation rejects bad input before the API is called.
run "$BIN ip not-an-ip"
assert_rc "invalid ip returns 1" 1
assert_stderr_contains "error mentions invalid format" "invalid ip format"

# Live JSON validation when a sandbox token is available.
if [ -n "${OPENAPI_SANDBOX_TOKEN:-}" ]; then
  run "OPENAPI_SANDBOX_TOKEN=$OPENAPI_SANDBOX_TOKEN $BIN --sandbox ip 8.8.8.8"
  assert_rc "sandbox ip returns 0" 0
  assert_json "sandbox ip returns JSON"

  run "OPENAPI_SANDBOX_TOKEN=$OPENAPI_SANDBOX_TOKEN $BIN --sandbox ip 8.8.8.8 --detail"
  assert_rc "sandbox ip --detail returns 0" 0
  assert_json "sandbox ip --detail returns JSON"
fi

summary
