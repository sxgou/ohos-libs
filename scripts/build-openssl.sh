#!/bin/sh
# Build OpenSSL for aarch64 HarmonyOS
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../config.sh"

SRC="openssl-3.0.15"
TARBALL="${SRC}.tar.gz"
URL="https://github.com/openssl/openssl/releases/download/${SRC}/${TARBALL}"

cd "$WORK"
[ -f "$TARBALL" ] || curl -sLO "$URL"
rm -rf "$SRC"; tar xzf "$TARBALL"; cd "$SRC"

# OpenSSL has its own config system (Configure, not autotools configure)
# Use linux-aarch64 target with OHOS clang as CC
./Configure linux-aarch64 \
  --prefix="$PREFIX" \
  --libdir=lib \
  no-shared no-tests no-dso no-engine \
  no-afalgeng no-async no-atexit \
  CC="${CC}" \
  CFLAGS="${CFLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  AR="${AR}" \
  > configure.log 2>&1

make -j"$JOBS" >> make.log 2>&1
make install_sw >> install.log 2>&1

echo "=== OpenSSL done ==="
echo "  lib: libssl.a, libcrypto.a"
echo "  headers: include/openssl/"
