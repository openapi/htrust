#!/usr/bin/env bash
# Example/test for: htrust email
#
# Usage:
#   htrust email info@example.com
#   htrust email info@example.com --detail
#   htrust --sandbox email info@example.com --detail

set -euo pipefail
source "$(dirname "$0")/lib.sh"
require_binary

section "htrust email"

# Without a token the command fails fast with a clear error.
clear_tokens
run_cmd "\"$HTRUST\" email info@example.com"
assert_rc "email fails without token" 1 "$rc"
assert_contains "error mentions OPENAPI_TOKEN" "OPENAPI_TOKEN" "$stderr"

# A positional value is required.
run_cmd "\"$HTRUST\" email"
assert_rc "email without value fails" 2 "$rc"
assert_contains "usage is printed" "Usage:" "$stderr"

# With a sandbox token we can call the live API.
if [ -n "${OPENAPI_SANDBOX_TOKEN:-}" ]; then
  run_cmd "env OPENAPI_SANDBOX_TOKEN=$OPENAPI_SANDBOX_TOKEN \"$HTRUST\" --sandbox email info@example.com"
  assert_rc "sandbox email returns success" 0 "$rc"
  assert_valid_json "sandbox email returns JSON" "$stdout"

  run_cmd "env OPENAPI_SANDBOX_TOKEN=$OPENAPI_SANDBOX_TOKEN \"$HTRUST\" --sandbox email info@example.com --detail"
  assert_rc "sandbox email --detail returns success" 0 "$rc"
  assert_valid_json "sandbox email --detail returns JSON" "$stdout"
else
  log_skip "live sandbox email tests (set OPENAPI_SANDBOX_TOKEN to enable)"
fi

summary
