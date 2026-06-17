#!/usr/bin/env bash
# Negative / side-case asserts for: htrust info

set -euo pipefail
source "$(dirname "$0")/lib.sh"
require_bin

echo "==> info asserts"

# info accepts --help-like usage via the main CLI.
run "$BIN --help"
assert_stdout_contains "--help shows usage" "info"
assert_rc "--help returns 0" 0

# info works in both modes without any token.
unset OPENAPI_TOKEN OPENAPI_SANDBOX_TOKEN
run "$BIN info"
assert_rc "info without token returns 0" 0
assert_stdout_contains "info shows runtime" "htrust runtime"

run "$BIN --sandbox info"
assert_rc "--sandbox info without token returns 0" 0
assert_stdout_contains "sandbox info shows sandbox=true" "sandbox: true"

summary
