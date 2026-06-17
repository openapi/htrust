#!/usr/bin/env bash
# Practical smoke test for: htrust info
#
# Usage shown below is executed literally.

set -euo pipefail

BIN=./target/release/htrust
[ -x "$BIN" ] || cargo build --release

set -x

$BIN info
$BIN --sandbox info
