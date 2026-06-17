#!/usr/bin/env bash
# Example/test for: htrust mobile
#
# Usage:
#   htrust mobile +393331234567
#   htrust mobile +393331234567 --detail
#   htrust --sandbox mobile +393331234567 --detail

set -euo pipefail
source "$(dirname "$0")/lib.sh"
require_binary

section "htrust mobile"

# Without a token the command fails fast with a clear error.
clear_tokens
run_cmd "\"$HTRUST\" mobile +393331234567"
assert_rc "mobile fails without token" 1 "$rc"
assert_contains "error mentions OPENAPI_TOKEN" "OPENAPI_TOKEN" "$stderr"

# A positional value is required.
run_cmd "\"$HTRUST\" mobile"
assert_rc "mobile without value fails" 2 "$rc"
assert_contains "usage is printed" "Usage:" "$stderr"

# With a sandbox token we can call the live API.
if [ -n "${OPENAPI_SANDBOX_TOKEN:-}" ]; then
  run_cmd "env OPENAPI_SANDBOX_TOKEN=$OPENAPI_SANDBOX_TOKEN \"$HTRUST\" --sandbox mobile +393331234567"
  assert_rc "sandbox mobile returns success" 0 "$rc"
  assert_valid_json "sandbox mobile returns JSON" "$stdout"

  run_cmd "env OPENAPI_SANDBOX_TOKEN=$OPENAPI_SANDBOX_TOKEN \"$HTRUST\" --sandbox mobile +393331234567 --detail"
  assert_rc "sandbox mobile --detail returns success" 0 "$rc"
  assert_valid_json "sandbox mobile --detail returns JSON" "$stdout"
else
  log_skip "live sandbox mobile tests (set OPENAPI_SANDBOX_TOKEN to enable)"
fi

summary
