#!/usr/bin/env bash
# Run every negative-case / side-case assert test under tests/asserts/.

set -euo pipefail

cd "$(dirname "$0")/../.."

[ -x ./target/release/htrust ] || cargo build --release

failed=0
for test_file in tests/asserts/test_*_asserts.sh; do
  [ -e "$test_file" ] || continue
  echo ""
  echo "===> $test_file"
  if bash "$test_file"; then
    :
  else
    failed=$((failed + 1))
  fi
done

echo ""
if [ "$failed" -eq 0 ]; then
  echo "All assert tests passed."
else
  echo "$failed assert test file(s) failed." >&2
  exit 1
fi
