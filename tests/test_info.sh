#!/usr/bin/env bash
# Example/test for: htrust info
#
# Usage:
#   htrust info
#   htrust --sandbox info
#
# info prints runtime configuration and does not need an API token.

set -euo pipefail
source "$(dirname "$0")/lib.sh"
require_binary

section "htrust info"

# Basic usage: print runtime status.
run_cmd "\"$HTRUST\" info"
assert_rc "info returns success" 0 "$rc"
assert_contains "info shows runtime header" "htrust runtime" "$stdout"
assert_contains "info shows sandbox flag" "sandbox:" "$stdout"
assert_contains "info shows token status" "token env:" "$stdout"

# Sandbox mode is reflected in the output.
run_cmd "\"$HTRUST\" --sandbox info"
assert_rc "--sandbox info returns success" 0 "$rc"
assert_contains "sandbox info shows sandbox=true" "sandbox: true" "$stdout"

summary
