#!/usr/bin/env bash
# Practical smoke test for: htrust info
#
# Usage shown below is executed literally.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
[ -x "$PROJECT_ROOT/target/release/htrust" ] || cargo build --release
export PATH="$PROJECT_ROOT/target/release:$PATH"

set -x

htrust info
htrust --sandbox info
