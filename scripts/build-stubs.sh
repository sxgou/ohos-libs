#!/bin/sh
# Build stub shared libraries for HarmonyOS musl-incompatible functions
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../config.sh"

STUBS_DIR="$(cd "$SCRIPT_DIR/../stubs" && pwd)"

# ----- libmuslstubs.so: stub implementations for missing musl functions -----
echo "--- libmuslstubs.so ---"
$CC -shared -fPIC -o "$PREFIX/lib/libmuslstubs.so" "$STUBS_DIR/musl_stubs.c" \
  --sysroot="$SYSROOT" -nostdlib

# ----- libbacktrace_stub.so: stub for backtrace functions -----
echo "--- libbacktrace_stub.so ---"
$CC -shared -fPIC -o "$PREFIX/lib/libbacktrace_stub.so" "$STUBS_DIR/backtrace_stub.c" \
  --sysroot="$SYSROOT" -nostdlib

echo "=== stubs done ==="
