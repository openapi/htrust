#!/usr/bin/env bash
# Practical smoke test for: htrust url
#
# Usage shown below is executed literally.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
[ -x "$PROJECT_ROOT/target/release/htrust" ] || cargo build --release
export PATH="$PROJECT_ROOT/target/release:$PATH"

# Make sure these tests do not accidentally pick up environment tokens.
unset OPENAPI_TOKEN OPENAPI_SANDBOX_TOKEN

set -x

# Without a token this must fail.
if htrust url https://example.com >/tmp/url-err 2>&1; then
  echo "FAIL: url should fail without a token" >&2
  exit 1
fi
grep -q OPENAPI_TOKEN /tmp/url-err

# Missing value must fail.
if htrust url >/tmp/url-err 2>&1; then
  echo "FAIL: url should fail without a value" >&2
  exit 1
fi

# Invalid format must be rejected locally, before any API call.
if htrust url not-a-url >/tmp/url-err 2>&1; then
  echo "FAIL: invalid url should be rejected locally" >&2
  exit 1
fi
grep -q "invalid url format" /tmp/url-err

# Live sandbox call, only if a token is available.
if [ -n "${OPENAPI_SANDBOX_TOKEN:-}" ]; then
  OPENAPI_SANDBOX_TOKEN="$OPENAPI_SANDBOX_TOKEN" htrust --sandbox url https://example.com
  OPENAPI_SANDBOX_TOKEN="$OPENAPI_SANDBOX_TOKEN" htrust --sandbox url https://example.com --detail
  OPENAPI_SANDBOX_TOKEN="$OPENAPI_SANDBOX_TOKEN" htrust --sandbox url https://example.com --json
fi
