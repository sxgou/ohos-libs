#!/bin/sh
# Build pixman for aarch64 HarmonyOS
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../config.sh"

SRC="pixman-0.42.2"
TARBALL="${SRC}.tar.gz"
URL="https://www.cairographics.org/releases/${TARBALL}"

cd "$WORK"
[ -f "$TARBALL" ] || curl -sLO "$URL"
rm -rf "$SRC"; tar xzf "$TARBALL"

# Patch config.sub for OHOS
[ -f "$SRC/config.sub" ] && sed -i 's/-qnx\*)/-qnx*|-ohos*)/' "$SRC/config.sub" 2>/dev/null || true

BUILD_DIR="$WORK/${SRC}-build"
rm -rf "$BUILD_DIR" && mkdir -p "$BUILD_DIR" && cd "$BUILD_DIR"

"$WORK/$SRC/configure" \
  --prefix="$PREFIX" --host=aarch64-linux-gnu --build=aarch64-linux-gnu \
  --enable-shared=no --enable-static=yes \
  --disable-arm-a64-neon --disable-arm-neon --disable-arm-simd \
  --disable-arm-iwmmxt --disable-gcc-inline-asm

# Fix config.status for HarmonyOS temp dir issue
cs="config.status"
sed -i 's/mktemp -d "\.\/confXXXXXX"/mkdir -p .\/conftmp/g' "$cs"
sed -i "s/ECHO='print -r --'/ECHO='echo'/" "$cs"
CONFIG_SHELL=/bin/sh /bin/sh ./config.status

# Fix libtool
sed -i '1s|#! /bin/sh|#!/data/service/hnp/bin/bash|' libtool 2>/dev/null || true
sed -i 's/print -r --/echo/g' libtool 2>/dev/null || true
sed -i 's/umask 077//g' libtool 2>/dev/null || true

make -j"$JOBS" && make install

echo "=== pixman done ==="
