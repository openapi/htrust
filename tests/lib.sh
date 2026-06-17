#!/usr/bin/env bash
# Test helpers for the htrust Bash test suite.
# This file is sourced by run.sh; it is not meant to be executed directly.

set -euo pipefail

FAILED=0
PASSED=0
SKIPPED=0

# Colors (disabled when NO_COLOR is set or output is not a TTY)
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  C_RED='\033[0;31m'
  C_GREEN='\033[0;32m'
  C_YELLOW='\033[0;33m'
  C_BLUE='\033[0;34m'
  C_RESET='\033[0m'
else
  C_RED=''
  C_GREEN=''
  C_YELLOW=''
  C_BLUE=''
  C_RESET=''
fi

log_info() {
  printf "${C_BLUE}INFO${C_RESET}  %s\n" "$*"
}

log_pass() {
  printf "${C_GREEN}PASS${C_RESET}  %s\n" "$*"
  PASSED=$((PASSED + 1))
}

log_fail() {
  printf "${C_RED}FAIL${C_RESET}  %s\n" "$*" >&2
  FAILED=$((FAILED + 1))
}

log_skip() {
  printf "${C_YELLOW}SKIP${C_RESET}  %s\n" "$*"
  SKIPPED=$((SKIPPED + 1))
}

summary() {
  printf "\n"
  printf "Results: %s passed, %s failed, %s skipped\n" "$PASSED" "$FAILED" "$SKIPPED"
  [ "$FAILED" -eq 0 ]
}

# Run a command, capturing stdout and stderr separately.
# Sets $rc, $stdout, $stderr.
run_cmd() {
  local tmpdir
  tmpdir=$(mktemp -d)
  stdout="$tmpdir/stdout"
  stderr="$tmpdir/stderr"
  # shellcheck disable=SC2294
  eval "$@" > "$stdout" 2> "$stderr" || rc=$?
  rc=${rc:-0}
  stdout=$(cat "$stdout")
  stderr=$(cat "$stderr")
  rm -rf "$tmpdir"
}

assert_eq() {
  local name="$1"
  local expected="$2"
  local actual="$3"
  if [ "$expected" = "$actual" ]; then
    log_pass "$name"
  else
    log_fail "$name: expected '$expected', got '$actual'"
  fi
}

assert_contains() {
  local name="$1"
  local needle="$2"
  local haystack="$3"
  if echo "$haystack" | grep -q "$needle"; then
    log_pass "$name"
  else
    log_fail "$name: output does not contain '$needle'"
  fi
}

assert_not_contains() {
  local name="$1"
  local needle="$2"
  local haystack="$3"
  if echo "$haystack" | grep -q "$needle"; then
    log_fail "$name: output unexpectedly contains '$needle'"
  else
    log_pass "$name"
  fi
}

assert_rc() {
  local name="$1"
  local expected="$2"
  local actual="$3"
  if [ "$expected" = "$actual" ]; then
    log_pass "$name"
  else
    log_fail "$name: expected exit code $expected, got $actual"
  fi
}

assert_valid_json() {
  local name="$1"
  local input="$2"
  if echo "$input" | jq empty 2>/dev/null; then
    log_pass "$name"
  else
    log_fail "$name: output is not valid JSON"
  fi
}

# Clear tokens so commands that require auth fail predictably.
clear_tokens() {
  unset OPENAPI_TOKEN OPENAPI_SANDBOX_TOKEN
}
