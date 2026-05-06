#!/bin/sh
# Build GMP for aarch64 HarmonyOS
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../config.sh"

SRC="gmp-6.3.0"
TARBALL="${SRC}.tar.xz"
URL="https://ftp.gnu.org/gnu/gmp/${TARBALL}"

cd "$WORK"
[ -f "$TARBALL" ] || curl -sLO "$URL"
rm -rf "$SRC"; tar xJf "$TARBALL"

# Patch config.sub for OHOS
[ -f "$SRC/config.sub" ] && sed -i 's/-qnx\*)/-qnx*|-ohos*)/' "$SRC/config.sub" 2>/dev/null || true

BUILD_DIR="$WORK/${SRC}-build"
rm -rf "$BUILD_DIR" && mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR"

"$WORK/$SRC/configure" \
  --prefix="$PREFIX" --host=aarch64-linux-gnu --build=aarch64-linux-gnu \
  --enable-shared=no --enable-static=yes

# Fix config.status
cs="config.status"
sed -i 's/mktemp -d "\.\/confXXXXXX"/mkdir -p .\/conftmp/g' "$cs"
sed -i "s/ECHO='print -r --'/ECHO='echo'/" "$cs"
CONFIG_SHELL=/bin/sh /bin/sh ./config.status

# Fix libtool
sed -i '1s|#! /bin/sh|#!/data/service/hnp/bin/bash|' libtool 2>/dev/null || true
sed -i 's/print -r --/echo/g' libtool 2>/dev/null || true
sed -i 's/umask 077//g' libtool 2>/dev/null || true

make -j"$JOBS" && make install

echo "=== gmp done ==="
