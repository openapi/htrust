#!/usr/bin/env bash
# htrust Bash test suite runner.
#
# Runs every test_*.sh file under this directory. Each file is a self-contained
# example of how one htrust command works.
#
# Usage:
#   ./tests/run.sh
#   OPENAPI_SANDBOX_TOKEN=xxx ./tests/run.sh
#   ./tests/test_mobile.sh        # run a single command test

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/lib.sh
source "$SCRIPT_DIR/lib.sh"

log_info "Project root: $PROJECT_ROOT"
require_binary
log_info "Using binary: $HTRUST"

# Sanity-check the binary itself.
section "htrust --help / --version"
run_cmd "\"$HTRUST\" --help"
assert_contains "--help prints usage" "htrust" "$stdout"
assert_rc "--help returns success" 0 "$rc"

run_cmd "\"$HTRUST\" --version"
assert_contains "--version prints version" "htrust" "$stdout"
assert_rc "--version returns success" 0 "$rc"

run_cmd "\"$HTRUST\""
assert_contains "no subcommand prints help" "Usage:" "$stdout"

# Run each per-command test file.
failed_files=0
for test_file in "$SCRIPT_DIR"/test_*.sh; do
  [ -e "$test_file" ] || continue
  printf "\n"
  log_info "Running $(basename "$test_file") ..."
  if bash "$test_file"; then
    :
  else
    failed_files=$((failed_files + 1))
  fi
done

printf "\n"
if [ "$failed_files" -eq 0 ]; then
  log_info "All test files passed."
else
  log_fail "$failed_files test file(s) failed."
  exit 1
fi
