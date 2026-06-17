#!/usr/bin/env bash
# Example/test for: htrust url
#
# Usage:
#   htrust url https://example.com
#   htrust url https://example.com --detail
#   htrust --sandbox url https://example.com

set -euo pipefail
source "$(dirname "$0")/lib.sh"
require_binary

section "htrust url"

# Without a token the command fails fast with a clear error.
clear_tokens
run_cmd "\"$HTRUST\" url https://example.com"
assert_rc "url fails without token" 1 "$rc"
assert_contains "error mentions OPENAPI_TOKEN" "OPENAPI_TOKEN" "$stderr"

# A positional value is required.
run_cmd "\"$HTRUST\" url"
assert_rc "url without value fails" 2 "$rc"
assert_contains "usage is printed" "Usage:" "$stderr"

# With a sandbox token we can call the live API.
if [ -n "${OPENAPI_SANDBOX_TOKEN:-}" ]; then
  run_cmd "env OPENAPI_SANDBOX_TOKEN=$OPENAPI_SANDBOX_TOKEN \"$HTRUST\" --sandbox url https://example.com"
  assert_rc "sandbox url returns success" 0 "$rc"
  assert_valid_json "sandbox url returns JSON" "$stdout"

  # --detail is accepted for interface consistency but maps to the same endpoint.
  run_cmd "env OPENAPI_SANDBOX_TOKEN=$OPENAPI_SANDBOX_TOKEN \"$HTRUST\" --sandbox url https://example.com --detail"
  assert_rc "sandbox url --detail returns success" 0 "$rc"
  assert_valid_json "sandbox url --detail returns JSON" "$stdout"
else
  log_skip "live sandbox url tests (set OPENAPI_SANDBOX_TOKEN to enable)"
fi

summary
