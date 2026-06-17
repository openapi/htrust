#!/usr/bin/env bash
# Minimal helpers for negative-case / side-case assert tests.
# These tests verify how htrust behaves when given bad or missing input.

set -euo pipefail

PASS=0
FAIL=0

BIN=./target/release/htrust

pass() {
  echo "  PASS $1"
  PASS=$((PASS + 1))
}

fail() {
  echo "  FAIL $1" >&2
  FAIL=$((FAIL + 1))
}

require_bin() {
  [ -x "$BIN" ] || cargo build --release
}

# Run a command and capture rc/stdout/stderr.
run() {
  rc=0
  stdout=$(mktemp)
  stderr=$(mktemp)
  # shellcheck disable=SC2294
  eval "$@" >"$stdout" 2>"$stderr" || rc=$?
  STDOUT=$(cat "$stdout")
  STDERR=$(cat "$stderr")
  rm -f "$stdout" "$stderr"
}

assert_rc() {
  local name="$1" want="$2"
  if [ "$want" -eq "$rc" ]; then
    pass "$name"
  else
    fail "$name: expected exit code $want, got $rc"
  fi
}

assert_stderr_contains() {
  local name="$1" needle="$2"
  if echo "$STDERR" | grep -q "$needle"; then
    pass "$name"
  else
    fail "$name: stderr does not contain '$needle'"
  fi
}

assert_stdout_contains() {
  local name="$1" needle="$2"
  if echo "$STDOUT" | grep -q "$needle"; then
    pass "$name"
  else
    fail "$name: stdout does not contain '$needle'"
  fi
}

assert_json() {
  local name="$1"
  if echo "$STDOUT" | jq empty 2>/dev/null; then
    pass "$name"
  else
    fail "$name: stdout is not valid JSON"
  fi
}

summary() {
  echo ""
  echo "Asserts: $PASS passed, $FAIL failed"
  [ "$FAIL" -eq 0 ]
}
