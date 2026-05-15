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

# ----- libuv.so: stub for libuv (needed by httpuv R package) -----
echo "--- libuv.so ---"
$CC -shared -fPIC -o "$PREFIX/lib/libuv.so" "$STUBS_DIR/libuv_stub.c" \
  --sysroot="$SYSROOT"

# ----- libextstubs.so: combined stubs for curl/crypto/ssl/zmq symbols -----
echo "--- libextstubs.so ---"
$CC -shared -fPIC -o "$PREFIX/lib/libextstubs.so" "$STUBS_DIR/ext_stubs.c" \
  --sysroot="$SYSROOT"

# ----- libgmp.so: stub for GNU Multiple Precision Arithmetic (when .a not linked) -----
echo "--- libgmp.so ---"
$CC -shared -fPIC -o "$PREFIX/lib/libgmp.so" "$STUBS_DIR/gmp_stub.c" \
  --sysroot="$SYSROOT"

# ----- libpng16.so: stub for libpng (when .a not linked) -----
echo "--- libpng16.so ---"
$CC -shared -fPIC -o "$PREFIX/lib/libpng16.so" "$STUBS_DIR/png_stub.c" \
  --sysroot="$SYSROOT"

# ----- libjvm.so: stub for Java JNI (needed by rJava) -----
echo "--- libjvm.so ---"
$CC -shared -fPIC -o "$PREFIX/lib/libjvm.so" "$STUBS_DIR/jvm_stub.c" \
  --sysroot="$SYSROOT" -nostdlib

# ----- libV8.so: stub for V8 JavaScript engine (needed by V8 R package) -----
echo "--- libV8.so ---"
$CC -shared -fPIC -o "$PREFIX/lib/libV8.so" "$STUBS_DIR/v8_stub.c" \
  --sysroot="$SYSROOT" -nostdlib

# ----- libgfortran_shim.so: additional gfortran stubs -----
echo "--- libgfortran_shim.so ---"
$CC -shared -fPIC -o "$PREFIX/lib/libgfortran_shim.so" "$STUBS_DIR/gfortran_stub.c" \
  --sysroot="$SYSROOT" -nostdlib

echo "=== stubs done ==="
