#!/bin/sh
# Build bzip2 for aarch64 HarmonyOS
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../config.sh"

SRC="bzip2-1.0.8"
TARBALL="${SRC}.tar.gz"
URL="https://sourceware.org/pub/bzip2/${TARBALL}"

cd "$WORK"
[ -f "$TARBALL" ] || curl -sLO "$URL"
rm -rf "$SRC"; tar xzf "$TARBALL"; cd "$SRC"

make -j"$JOBS" CC="$CC" LDFLAGS="$LDFLAGS" CFLAGS="$CFLAGS -fPIC" libbz2.a libbz2.so
cp libbz2.a "$PREFIX/lib/" && cp bzlib.h "$PREFIX/include/"

echo "=== bzip2 done ==="
