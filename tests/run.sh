#!/usr/bin/env bash
# Run every practical smoke test under tests/test_*.sh.
# Each file shows the real htrust commands being executed.

set -euo pipefail

cd "$(dirname "$0")/.."

[ -x ./target/release/htrust ] || cargo build --release

for test_file in tests/test_*.sh; do
  echo ""
  echo "===> $test_file"
  bash "$test_file"
done

echo ""
echo "All smoke tests passed."
