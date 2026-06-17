#!/usr/bin/env bash
# Example/test for: htrust ip
#
# Usage:
#   htrust ip 8.8.8.8
#   htrust ip 8.8.8.8 --detail
#   htrust --sandbox ip 8.8.8.8

set -euo pipefail
source "$(dirname "$0")/lib.sh"
require_binary

section "htrust ip"

# Without a token the command fails fast with a clear error.
clear_tokens
run_cmd "\"$HTRUST\" ip 8.8.8.8"
assert_rc "ip fails without token" 1 "$rc"
assert_contains "error mentions OPENAPI_TOKEN" "OPENAPI_TOKEN" "$stderr"

# A positional value is required.
run_cmd "\"$HTRUST\" ip"
assert_rc "ip without value fails" 2 "$rc"
assert_contains "usage is printed" "Usage:" "$stderr"

# With a sandbox token we can call the live API.
if [ -n "${OPENAPI_SANDBOX_TOKEN:-}" ]; then
  run_cmd "env OPENAPI_SANDBOX_TOKEN=$OPENAPI_SANDBOX_TOKEN \"$HTRUST\" --sandbox ip 8.8.8.8"
  assert_rc "sandbox ip returns success" 0 "$rc"
  assert_valid_json "sandbox ip returns JSON" "$stdout"

  # --detail is accepted for interface consistency but maps to the same endpoint.
  run_cmd "env OPENAPI_SANDBOX_TOKEN=$OPENAPI_SANDBOX_TOKEN \"$HTRUST\" --sandbox ip 8.8.8.8 --detail"
  assert_rc "sandbox ip --detail returns success" 0 "$rc"
  assert_valid_json "sandbox ip --detail returns JSON" "$stdout"
else
  log_skip "live sandbox ip tests (set OPENAPI_SANDBOX_TOKEN to enable)"
fi

summary
