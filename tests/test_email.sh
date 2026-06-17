#!/usr/bin/env bash
# Practical smoke test for: htrust email
#
# Usage shown below is executed literally.

set -euo pipefail

BIN=./target/release/htrust
[ -x "$BIN" ] || cargo build --release

# Make sure these tests do not accidentally pick up environment tokens.
unset OPENAPI_TOKEN OPENAPI_SANDBOX_TOKEN

set -x

# Without a token this must fail.
if $BIN email info@example.com >/tmp/email-err 2>&1; then
  echo "FAIL: email should fail without a token" >&2
  exit 1
fi
grep -q OPENAPI_TOKEN /tmp/email-err

# Missing value must fail.
if $BIN email >/tmp/email-err 2>&1; then
  echo "FAIL: email should fail without a value" >&2
  exit 1
fi

# Live sandbox call, only if a token is available.
if [ -n "${OPENAPI_SANDBOX_TOKEN:-}" ]; then
  OPENAPI_SANDBOX_TOKEN="$OPENAPI_SANDBOX_TOKEN" $BIN --sandbox email info@example.com
  OPENAPI_SANDBOX_TOKEN="$OPENAPI_SANDBOX_TOKEN" $BIN --sandbox email info@example.com --detail
fi
