#!/usr/bin/env bash
# Practical smoke test for: htrust mobile
#
# Usage shown below is executed literally.

set -euo pipefail

BIN=./target/release/htrust
[ -x "$BIN" ] || cargo build --release

# Make sure these tests do not accidentally pick up environment tokens.
unset OPENAPI_TOKEN OPENAPI_SANDBOX_TOKEN

set -x

# Without a token this must fail.
if $BIN mobile +393331234567 >/tmp/mobile-err 2>&1; then
  echo "FAIL: mobile should fail without a token" >&2
  exit 1
fi
grep -q OPENAPI_TOKEN /tmp/mobile-err

# Missing value must fail.
if $BIN mobile >/tmp/mobile-err 2>&1; then
  echo "FAIL: mobile should fail without a value" >&2
  exit 1
fi

# Live sandbox call, only if a token is available.
if [ -n "${OPENAPI_SANDBOX_TOKEN:-}" ]; then
  OPENAPI_SANDBOX_TOKEN="$OPENAPI_SANDBOX_TOKEN" $BIN --sandbox mobile +393331234567
  OPENAPI_SANDBOX_TOKEN="$OPENAPI_SANDBOX_TOKEN" $BIN --sandbox mobile +393331234567 --detail
fi
